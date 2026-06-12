# Mobile Banking Authentication Sequence Flow

## Overview

This sequence flow models a secure mobile banking login process with password validation, rate limiting, OTP verification, account lockout, and JWT token issuance.

## Sequence Diagram

```mermaid
sequenceDiagram
    participant Customer
    participant MobileApp as Mobile App
    participant Gateway as API Gateway
    participant Auth as Auth Service
    participant DB as Database
    participant SMS as SMS Provider

    Customer->>MobileApp: Enter customer ID and password
    MobileApp->>MobileApp: Validate fields and format
    MobileApp->>Gateway: POST /auth/login
    Gateway->>Gateway: Rate limit check

    alt Too many requests
        Gateway-->>MobileApp: 429 Too Many Requests
    else Within limit
        Gateway->>Auth: Forward credentials
        Auth->>DB: Lookup customer by ID
        DB-->>Auth: Customer record
        Auth->>Auth: Verify password hash and account status

        alt Invalid password
            Auth->>DB: Increment failure counter
            alt Three failures
                Auth->>DB: Lock account
                Auth-->>Gateway: 423 Locked
            else Fewer than three failures
                Auth-->>Gateway: 401 Unauthorized
            end
            Gateway-->>MobileApp: Error response
        else Valid password and active account
            Auth->>Auth: Generate OTP
            Auth->>DB: Store OTP with expiry
            Auth->>SMS: Send OTP to registered mobile
            SMS-->>Customer: OTP message
            Auth-->>Gateway: OTP challenge required
            Gateway-->>MobileApp: 200 OTP Required
        end
    end

    Customer->>MobileApp: Enter OTP
    MobileApp->>Gateway: POST /auth/verify-otp
    Gateway->>Auth: Forward OTP
    Auth->>DB: Validate OTP and expiry

    alt OTP invalid or expired
        Auth-->>Gateway: 401 OTP invalid
        Gateway-->>MobileApp: 401 OTP invalid
    else OTP valid
        Auth->>Auth: Generate signed JWT
        Auth->>DB: Store session
        Auth-->>Gateway: 200 OK + JWT
        Gateway-->>MobileApp: 200 OK + JWT
        MobileApp->>MobileApp: Store token securely
    end
```

## Flow Explanation

1. Customer enters ID and password in the mobile app.
2. The app validates empty fields and format locally.
3. The app sends `POST /auth/login` to the API Gateway.
4. API Gateway checks rate limits before forwarding credentials.
5. Auth Service verifies customer ID, password hash, and account status.
6. Wrong password returns `401` and increments failure counter.
7. Three failed attempts lock the account and return `423`.
8. Valid password triggers OTP generation.
9. OTP is stored with expiry and sent through SMS.
10. Customer submits OTP through `POST /auth/verify-otp`.
11. Auth Service validates OTP and expiry.
12. Successful verification creates a signed JWT and session record.
13. Mobile app stores the token securely and uses it in the `Authorization` header.

## Security Controls

- Local input validation
- API gateway rate limiting
- Password hash verification
- Account status check
- Failed login counter
- Lockout after repeated failures
- OTP expiry
- JWT signing
- Session persistence
- Authorization header for subsequent API calls

## Product Relevance

The flow balances security and user experience. It also shows where product owners can define policies such as lockout threshold, OTP expiry window, session lifetime, and fallback recovery path.

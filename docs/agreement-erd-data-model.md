# Agreement ERD Data Model

## Business Context

Banking agreements involve multiple party roles, agreement types, lifecycle statuses, legal entities, individual customers, parent-child party hierarchies, and multiple address types.

The model below keeps agreement data normalized while allowing the same `PARTY` table to represent banks, customers, legal entities, and individuals.

## Data Model Summary

1. `AGREEMENT` is the central table.
2. `PARTY` represents both bank and customer parties.
3. `AGREEMENT` points to `PARTY` twice: once for bank and once for customer.
4. `PARTY.parent_party_id` supports parent-child hierarchy.
5. `LEGAL_PARTY` and `INDIVIDUAL_PARTY` specialize party details.
6. `ADDRESS` stores legal and postal addresses in one table.
7. `AGREEMENT_TYPE` and `STATUS` are lookup tables.

## Mermaid ERD

```mermaid
erDiagram
    PARTY ||--o{ PARTY : "parent_child"
    PARTY ||--o{ ADDRESS : "has"
    PARTY ||--o| LEGAL_PARTY : "legal_profile"
    PARTY ||--o| INDIVIDUAL_PARTY : "individual_profile"
    PARTY ||--o{ AGREEMENT : "bank_party"
    PARTY ||--o{ AGREEMENT : "customer_party"
    AGREEMENT_TYPE ||--o{ AGREEMENT : "classifies"
    STATUS ||--o{ AGREEMENT : "tracks"

    PARTY {
        int party_id PK
        string party_name
        string role_party
        int parent_party_id FK
        string party_category
    }

    LEGAL_PARTY {
        int party_id PK,FK
        string registration_number
        string tax_id
        string legal_name
    }

    INDIVIDUAL_PARTY {
        int party_id PK,FK
        date date_of_birth
        string id_number
        string full_name
    }

    ADDRESS {
        int address_id PK
        int party_id FK
        string address_type
        string line_1
        string city
        string country
        string postal_code
    }

    AGREEMENT {
        int agreement_id PK
        int bank_party_id FK
        int customer_party_id FK
        int agreement_type_id FK
        int status_id FK
        date start_date
        date end_date
    }

    AGREEMENT_TYPE {
        int agreement_type_id PK
        string agreement_type_name
    }

    STATUS {
        int status_id PK
        string status_name
    }
```

## Design Explanation

### Agreement as Hub

`AGREEMENT` is the hub table. It has its own primary key and foreign keys to:

- Bank party
- Customer party
- Agreement type
- Agreement status

This keeps the agreement structure clean and extensible.

### Single Party Table

The model uses one `PARTY` table for both bank and customer. This avoids duplicating similar columns across separate customer and bank tables.

`role_party` identifies whether the party is acting as:

- Bank
- Customer
- Counterparty
- Guarantor
- Other banking relationship role

### Parent-Child Party Hierarchy

`parent_party_id` on `PARTY` points back to `PARTY.party_id`. This supports corporate hierarchy:

- Parent company
- Subsidiary
- Branch
- Legal entity group

### Legal vs Individual Party

A party can be legal or individual, not both.

`LEGAL_PARTY` stores company-related fields.

`INDIVIDUAL_PARTY` stores person-related fields.

Both link back to `PARTY` through `party_id`.

### Address Design

`ADDRESS` supports multiple address types:

- Legal address
- Postal address
- Billing address
- Registered office address

The `address_type` column keeps address handling flexible without creating separate tables for every address category.

## Banking Product Relevance

This ERD can support agreement search, contract ingestion, KYC enrichment, customer hierarchy analysis, credit exposure views, and GenAI-assisted contract metadata extraction.

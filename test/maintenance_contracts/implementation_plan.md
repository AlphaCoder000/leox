# Maintenance Contracts Testing Plan

This document outlines the testing plan for the **Maintenance Contracts (MC)** portal within the LeoX/LeoOpus codebase. To ensure clean organization and complete isolation, all MC test cases will reside in a separate directory: `test/maintenance_contracts/`.

---

## 1. Directory Structure

We will organize our tests inside `test/maintenance_contracts/` as follows:

```
test/maintenance_contracts/
├── implementation_plan.md         # This plan
├── unit/
│   ├── models/
│   │   ├── mc_provider_model_test.dart
│   │   ├── mc_request_model_test.dart
│   │   ├── mc_review_model_test.dart
│   │   ├── mc_seeker_model_test.dart
│   │   └── mc_service_model_test.dart
│   └── controllers/
│       ├── mc_provider_auth_controller_test.dart
│       ├── mc_seeker_auth_controller_test.dart
│       ├── mc_provider_dashboard_controller_test.dart
│       └── mc_seeker_dashboard_controller_test.dart
└── widget/
    ├── mc_provider_login_view_test.dart
    └── mc_seeker_dashboard_view_test.dart
```

---

## 2. Testing Strategies

To achieve stable, high-coverage testing without triggering Firebase initialisation issues or network dependency errors in test mode, we will employ two main strategies:

### A. Pure Model Unit Testing
* **Goal**: Test parsing logic (`fromJson`), serialization logic (`toJson`), fields, defaults, and boundary conditions.
* **Impact**: Ensures that data contracts between our app and Firebase are robust.

### B. Controller Logic & Clean Validation Testing
* **Goal**: Verify state changes, validation rules (email/password/phone), loading states, and exception boundaries.
* **Impact**: Tests controller logic cleanly, matching the "clean testing" paradigm seen in `employee_auth_provider_clean_test.dart`.

### C. Mocked Controller Widget Testing
* **Goal**: Verify UI rendering, error displays, loading spinners, form validation, and button interactivity.
* **Strategy**: Use Mockito to mock the controllers so that the UI can be tested without actual Firebase backend calls.

---

## 3. Step-by-Step Execution Plan

### Step 1: Model Unit Tests
We will write the five model tests to verify successful constructor validation, `fromJson` parsing (including default fallback values), and `toJson` serialization.
* [ ] Provider Model Test (`mc_provider_model_test.dart`)
* [ ] Seeker Model Test (`mc_seeker_model_test.dart`)
* [ ] Request Model Test (`mc_request_model_test.dart`)
* [ ] Service Model Test (`mc_service_model_test.dart`)
* [ ] Review Model Test (`mc_review_model_test.dart`)

### Step 2: Clean Controller Validation & Unit Tests
We will verify inputs (email, passwords, phone numbers, addresses, ratings, prices) and loading states under various scenarios.
* [ ] Provider Auth Validation Test (`mc_provider_auth_controller_test.dart`)
* [ ] Seeker Auth Validation Test (`mc_seeker_auth_controller_test.dart`)
* [ ] Provider Dashboard Controller Test (`mc_provider_dashboard_controller_test.dart`)
* [ ] Seeker Dashboard Controller Test (`mc_seeker_dashboard_controller_test.dart`)

### Step 3: Widget UI Interaction Tests
We will write UI tests using `mockito` to mock our controllers.
* [ ] Provider Login View Widget Test (`mc_provider_login_view_test.dart`)

### Step 4: Verification Run
Run the entire suite of `maintenance_contracts` tests using `flutter test test/maintenance_contracts/` to ensure 100% success.

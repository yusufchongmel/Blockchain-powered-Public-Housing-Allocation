# 🏠 Blockchain-Powered Public Housing Allocation

A transparent and efficient smart contract system for managing public housing allocation on the Stacks blockchain. This contract enables fair distribution of housing units based on priority scoring, eligibility criteria, and automated waitlist management.

## 🌟 Features

- 🏘️ **Housing Unit Management**: Add, update, and track housing units
- 📝 **Application System**: Submit and manage housing applications
- 🎯 **Priority-Based Allocation**: Automatic scoring based on income and household size
- 📋 **Waitlist Management**: Organized queue with priority positioning
- ✅ **Eligibility Verification**: Automated checking against configurable criteria
- 👨‍💼 **Administrative Controls**: Comprehensive management functions
- 🔒 **Security**: Role-based access control with contract owner permissions

## 📋 Contract Overview

### Key Components

#### Data Structures
- **Housing Units**: Properties with address, bedrooms, rent, and occupancy status
- **Applications**: User submissions with household info, income, and priority scores
- **Waitlist**: Queue system tracking application positions
- **Eligibility Criteria**: Configurable income and household size limits

#### Priority Scoring Algorithm
Applications are automatically scored based on:
- **Base Score**: 100 points
- **Income Multiplier**: 
  - ≤ $30,000: +50 points
  - ≤ $50,000: +30 points
  - > $50,000: +10 points
- **Family Bonus**: +20 points per household member beyond the first

## 🚀 Getting Started

### Prerequisites
- [Clarinet](https://docs.hiro.so/stacks/clarinet)
- [Node.js](https://nodejs.org/) (for testing)
- Stacks wallet for deployment

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd Blockchain-powered-Public-Housing-Allocation
```

2. Install dependencies:
```bash
npm install
```

3. Check contract syntax:
```bash
clarinet check
```

### Deployment

1. Deploy to testnet:
```bash
clarinet deploy --testnet
```

2. Deploy to mainnet:
```bash
clarinet deploy --mainnet
```

## 📖 Usage Guide

### For Applicants

#### 1. Submit Application 📝
```clarity
(contract-call? .Public-Housing-Allocation submit-application 
  household-size 
  monthly-income)
```
**Parameters:**
- `household-size`: Number of people in household
- `monthly-income`: Monthly income in microSTX

#### 2. Check Application Status 🔍
```clarity
(contract-call? .Public-Housing-Allocation get-applicant-application 
  'SP1ABC...XYZ)
```

#### 3. Withdraw Application ❌
```clarity
(contract-call? .Public-Housing-Allocation withdraw-application)
```

#### 4. Check Waitlist Position 📍
```clarity
(contract-call? .Public-Housing-Allocation get-waitlist-position 
  application-id)
```

### For Administrators

#### 1. Add Housing Unit 🏠
```clarity
(contract-call? .Public-Housing-Allocation add-housing-unit 
  "123 Main St, Apt 1A" 
  u2 
  u1500)
```
**Parameters:**
- `address`: Property address (string)
- `bedrooms`: Number of bedrooms
- `monthly-rent`: Rent amount in microSTX

#### 2. Allocate Unit to Applicant ✅
```clarity
(contract-call? .Public-Housing-Allocation allocate-unit 
  unit-id 
  application-id)
```

#### 3. Update Eligibility Criteria ⚙️
```clarity
(contract-call? .Public-Housing-Allocation update-eligibility-criteria 
  "max-income" 
  u75000)
```

#### 4. Control Application Status 🎛️
```clarity
(contract-call? .Public-Housing-Allocation set-allocation-status true)
```

#### 5. Reject Application ❌
```clarity
(contract-call? .Public-Housing-Allocation reject-application 
  application-id 
  "Income exceeds maximum")
```

### For Tenants

#### Vacate Unit 🏃‍♂️
```clarity
(contract-call? .Public-Housing-Allocation vacate-unit unit-id)
```

## 📊 Read-Only Functions

### Application Information
- `get-application(app-id)`: Get application details
- `get-applicant-application(applicant)`: Get user's application
- `is-application-pending(app-id)`: Check if application is pending
- `get-application-count()`: Total applications submitted

### Housing Information
- `get-housing-unit(unit-id)`: Get unit details
- `is-unit-available(unit-id)`: Check unit availability
- `get-unit-count()`: Total units in system

### System Information
- `get-contract-owner()`: Contract owner address
- `is-allocation-open()`: Check if applications are being accepted
- `get-eligibility-criteria(criteria-name)`: Get specific criteria value
- `calculate-priority-score(household-size, income)`: Calculate application priority
- `check-eligibility(household-size, income)`: Verify eligibility

## 🔧 Configuration

### Default Eligibility Criteria
- **Maximum Income**: $60,000 annually
- **Minimum Household Size**: 1 person

### Error Codes
- `u100`: Unauthorized access
- `u101`: Resource not found
- `u102`: Resource already exists
- `u103`: Invalid input parameters
- `u104`: Housing unit occupied
- `u105`: Insufficient eligibility
- `u106`: Application already allocated
- `u107`: Not eligible for housing

## 🧪 Testing

Run the test suite:
```bash
npm test
```s

Run specific tests:
```bash
npm test -- --grep "application submission"
```

## 🏗️ Architecture

### Smart Contract Structure
```
├── Constants & Error Codes
├── Data Variables (counters, settings)
├── Data Maps (units, applications, waitlist)
├── Read-Only Functions (getters, calculations)
├── Public Functions (core operations)
└── Private Functions (internal helpers)
```

### Key Design Decisions
- **Priority-based allocation** ensures fair distribution
- **Role-based access control** maintains security
- **Configurable criteria** allows policy flexibility
- **Automated scoring** reduces bias and manual processing
- **Transparent waitlist** provides clear expectations



## 📜 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.


## 🎯 Roadmap

- [ ] 🔗 Integration with external housing databases
- [ ] 📱 Mobile-friendly interface
- [ ] 🤖 AI-powered matching algorithms
- [ ] 📊 Advanced analytics dashboard
- [ ] 🌍 Multi-language support
- [ ] ⚡ Layer 2 scaling solutions

---

**Built with ❤️ on Stacks Blockchain**
# Epic 2: Data Input & Management

## US-006: CSV File Upload for Portfolio Data

**As a** retail investor  
**I want to** upload my brokerage CSV file  
**So that** I can quickly import all my positions without manual entry

### Acceptance Criteria
- [ ] Given I'm on the portfolio page, when I click "Upload CSV", then I see file upload dialog
- [ ] Given I select a valid CSV file, when I upload, then the file is processed and positions are displayed
- [ ] Given I upload Charles Schwab format, when processing completes, then all positions are correctly parsed
- [ ] Given I upload Fidelity format, when processing completes, then all positions are correctly parsed
- [ ] Given I upload TD Ameritrade format, when processing completes, then all positions are correctly parsed
- [ ] Given I upload invalid CSV format, when processing fails, then I see clear error message with format requirements
- [ ] Given file is too large (>10MB), when I upload, then I see file size error

**Priority:** High  
**Effort:** L  
**Dependencies:** US-002

**Technical Notes:**
- Support CSV formats: Charles Schwab, Fidelity, TD Ameritrade
- File size limit: 10MB
- CSV parsing library (Papa Parse)
- Error handling for malformed data
- Progress indicator for large files

---

## US-007: CSV Format Detection and Validation

**As a** user uploading a CSV file  
**I want to** have my file format automatically detected  
**So that** I don't need to specify which brokerage format I'm using

### Acceptance Criteria
- [ ] Given I upload a CSV, when processing starts, then the system detects the brokerage format automatically
- [ ] Given Schwab CSV format, when detected, then correct parser is applied
- [ ] Given Fidelity CSV format, when detected, then correct parser is applied
- [ ] Given TD Ameritrade CSV format, when detected, then correct parser is applied
- [ ] Given unknown CSV format, when detection fails, then I see format selection dropdown
- [ ] Given ambiguous format, when detection is uncertain, then I'm prompted to confirm format
- [ ] Given I manually select format, when I proceed, then selected parser is used

**Priority:** High  
**Effort:** M  
**Dependencies:** US-006

**Technical Notes:**
- Header pattern matching for format detection
- Fallback to manual selection
- Format confidence scoring
- Support for custom CSV mapping

---

## US-008: Real-time Data Validation During CSV Upload

**As a** user uploading portfolio data  
**I want to** see validation errors in real-time  
**So that** I can correct issues before finalizing the import

### Acceptance Criteria
- [ ] Given I upload CSV with invalid ticker symbols, when processing occurs, then I see list of invalid symbols
- [ ] Given I have negative quantities, when validation runs, then I see quantity warnings
- [ ] Given I have missing required fields, when validation runs, then I see field requirement errors
- [ ] Given I have duplicate positions, when validation runs, then I see duplicate warnings with merge option
- [ ] Given validation errors exist, when I try to proceed, then import is blocked until resolved
- [ ] Given I fix all errors, when validation passes, then I can proceed with import

**Priority:** High  
**Effort:** M  
**Dependencies:** US-007

**Technical Notes:**
- Real-time ticker symbol validation via API
- Business rule validation (quantities, prices)
- Duplicate detection and merging logic
- Error highlighting in CSV preview

---

## US-009: Manual Position Entry Form

**As a** retail investor  
**I want to** manually add individual stock positions  
**So that** I can input positions when I don't have CSV files or need to add single positions

### Acceptance Criteria
- [ ] Given I'm on portfolio page, when I click "Add Position", then I see position entry form
- [ ] Given I enter valid ticker symbol, when I tab out, then stock name and current price are auto-populated
- [ ] Given I enter quantity and average cost, when I save, then position is added to portfolio
- [ ] Given I enter invalid ticker, when I submit, then I see ticker validation error
- [ ] Given I leave required fields empty, when I submit, then I see field requirement errors
- [ ] Given successful entry, when position is saved, then it appears in portfolio table immediately

**Priority:** High  
**Effort:** S  
**Dependencies:** US-002

**Technical Notes:**
- Ticker symbol autocomplete
- Real-time price lookup
- Form validation and error handling
- Optimistic UI updates

---

## US-010: Edit and Delete Existing Positions

**As a** user with existing positions  
**I want to** edit or delete individual positions  
**So that** I can keep my portfolio data accurate and current

### Acceptance Criteria
- [ ] Given I have positions in my portfolio, when I click edit on a position, then I see edit form pre-filled
- [ ] Given I modify quantity or cost basis, when I save, then position is updated and metrics recalculated
- [ ] Given I click delete on a position, when I confirm, then position is removed from portfolio
- [ ] Given I edit a position, when I cancel, then changes are discarded
- [ ] Given I delete a position, when action completes, then portfolio totals are updated
- [ ] Given I have unsaved changes, when I try to navigate away, then I see confirmation dialog

**Priority:** Medium  
**Effort:** S  
**Dependencies:** US-009

**Technical Notes:**
- Inline editing capabilities
- Confirmation dialogs for destructive actions
- Real-time calculation updates
- Unsaved changes detection

---

## US-011: Multiple Portfolio Management

**As a** active investor  
**I want to** create and manage multiple portfolios  
**So that** I can track different investment strategies separately (e.g., retirement, trading, long-term)

### Acceptance Criteria
- [ ] Given I'm logged in, when I access portfolios page, then I see list of my portfolios
- [ ] Given I want to create new portfolio, when I click "New Portfolio", then I see creation form
- [ ] Given I enter portfolio name and description, when I save, then new portfolio is created
- [ ] Given I have multiple portfolios, when I switch between them, then correct positions are displayed
- [ ] Given I want to delete portfolio, when I confirm deletion, then portfolio and all positions are removed
- [ ] Given I rename a portfolio, when I save, then name is updated across the application

**Priority:** Medium  
**Effort:** M  
**Dependencies:** US-002

**Technical Notes:**
- Portfolio switching UI component
- Cascade deletion for portfolio positions
- Portfolio metadata storage
- Default portfolio assignment

---

## US-012: Bulk Position Import with Review

**As a** user importing large CSV files  
**I want to** review positions before final import  
**So that** I can verify accuracy and make adjustments before committing data

### Acceptance Criteria
- [ ] Given I upload a CSV, when processing completes, then I see preview table with all positions
- [ ] Given positions are in preview, when I review data, then I can edit individual positions
- [ ] Given I want to exclude positions, when I uncheck them, then they won't be imported
- [ ] Given I'm satisfied with preview, when I click "Import All", then positions are added to portfolio
- [ ] Given I want to cancel, when I click "Cancel", then no positions are imported
- [ ] Given large files, when processing occurs, then I see progress indicator

**Priority:** Medium  
**Effort:** M  
**Dependencies:** US-008

**Technical Notes:**
- Pagination for large datasets
- Bulk edit capabilities
- Import progress tracking
- Memory-efficient processing for large files
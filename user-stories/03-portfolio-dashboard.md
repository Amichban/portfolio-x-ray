# Epic 3: Portfolio Dashboard

## US-013: Portfolio Overview Summary

**As a** retail investor  
**I want to** see my portfolio's total value and key metrics at a glance  
**So that** I can quickly understand my investment performance

### Acceptance Criteria
- [ ] Given I have positions in my portfolio, when I access dashboard, then I see total portfolio value
- [ ] Given my portfolio has gains/losses, when I view overview, then I see total P&L in dollars and percentage
- [ ] Given I access dashboard, when page loads, then I see number of positions and asset allocation summary
- [ ] Given market hours, when I view dashboard, then values reflect current market prices
- [ ] Given after market hours, when I view dashboard, then I see last updated timestamp
- [ ] Given empty portfolio, when I access dashboard, then I see onboarding message to add positions

**Priority:** High  
**Effort:** M  
**Dependencies:** US-009, US-006

**Technical Notes:**
- Real-time price updates during market hours
- Efficient calculation caching
- Responsive design for mobile
- Loading states for slow connections

---

## US-014: Risk Metrics Display

**As a** active investor  
**I want to** see my portfolio's risk metrics (VaR, Beta, Sharpe ratio)  
**So that** I can understand the risk profile of my investments

### Acceptance Criteria
- [ ] Given my portfolio has positions, when I view risk section, then I see Value at Risk (VaR) at 95% confidence
- [ ] Given my portfolio, when calculations complete, then I see portfolio Beta relative to S&P 500
- [ ] Given my portfolio has performance history, when I view metrics, then I see Sharpe ratio
- [ ] Given my portfolio, when I view risk metrics, then I see maximum drawdown over time periods
- [ ] Given insufficient data, when calculations can't be performed, then I see appropriate messaging
- [ ] Given risk metrics, when I hover over each metric, then I see tooltip explaining the calculation

**Priority:** High  
**Effort:** L  
**Dependencies:** US-018 (Risk Calculations Engine)

**Technical Notes:**
- VaR calculation using historical simulation
- Beta calculation against S&P 500 benchmark
- Sharpe ratio with risk-free rate (10-year Treasury)
- Maximum drawdown calculation over 1Y, 3Y, 5Y periods
- Tooltip explanations for each metric

---

## US-015: Position-Level Concentration Analysis

**As a** portfolio manager  
**I want to** see which positions represent the largest concentration risks  
**So that** I can identify over-concentration in individual stocks

### Acceptance Criteria
- [ ] Given my portfolio, when I view concentration section, then I see positions ranked by portfolio percentage
- [ ] Given positions above 10% allocation, when displayed, then they're highlighted as concentration risks
- [ ] Given I want details, when I click on a position, then I see detailed position information
- [ ] Given concentration risks exist, when I view analysis, then I see recommendations to rebalance
- [ ] Given positions, when displayed, then I see both dollar amount and percentage allocation
- [ ] Given I filter by concentration threshold, when I adjust slider, then view updates dynamically

**Priority:** High  
**Effort:** M  
**Dependencies:** US-013

**Technical Notes:**
- Interactive concentration threshold slider
- Color coding for risk levels (green <5%, yellow 5-10%, red >10%)
- Sortable table by allocation percentage
- Drill-down capability to position details

---

## US-016: Sector-Level Concentration Analysis

**As a** diversification-focused investor  
**I want to** see my portfolio's sector allocation  
**So that** I can identify sector concentration risks

### Acceptance Criteria
- [ ] Given my portfolio, when I view sector analysis, then I see allocation by GICS sectors
- [ ] Given sector allocations, when displayed, then I see pie chart and table views
- [ ] Given sectors above 25% allocation, when shown, then they're flagged as over-concentrated
- [ ] Given I want to compare, when I view sectors, then I see S&P 500 sector allocation overlay
- [ ] Given sector data, when I hover over chart segments, then I see detailed breakdown
- [ ] Given I click on a sector, when selected, then I see all positions within that sector

**Priority:** High  
**Effort:** M  
**Dependencies:** US-015

**Technical Notes:**
- GICS sector classification for all holdings
- Interactive pie chart with drill-down
- Benchmark comparison overlay
- Sector rebalancing suggestions

---

## US-017: Historical Performance Visualization

**As a** performance-focused investor  
**I want to** see my portfolio's historical performance  
**So that** I can track progress and compare against benchmarks

### Acceptance Criteria
- [ ] Given my portfolio has history, when I view performance chart, then I see value over time
- [ ] Given performance data, when I select time periods (1M, 3M, 6M, 1Y, 3Y), then chart updates accordingly
- [ ] Given my performance, when displayed, then I see S&P 500 benchmark comparison
- [ ] Given I want details, when I hover over chart points, then I see specific date and value
- [ ] Given performance periods, when I view chart, then I see return percentages for each period
- [ ] Given portfolio changes, when positions are added/removed, then performance attribution is maintained

**Priority:** Medium  
**Effort:** L  
**Dependencies:** US-013

**Technical Notes:**
- Time-weighted return calculations
- Benchmark data integration
- Interactive charting library (Chart.js or D3)
- Performance attribution tracking
- Responsive chart design

---

## US-018: Dashboard Customization and Layout

**As a** user with specific analysis preferences  
**I want to** customize my dashboard layout  
**So that** I can prioritize the information most important to me

### Acceptance Criteria
- [ ] Given I'm on dashboard, when I access customization mode, then I can drag and drop widgets
- [ ] Given dashboard widgets, when I resize them, then layout adapts and is saved
- [ ] Given I don't want certain widgets, when I hide them, then they're removed from my view
- [ ] Given I customize layout, when I refresh page, then my preferences are preserved
- [ ] Given I want defaults, when I click "Reset Layout", then dashboard returns to original state
- [ ] Given different screen sizes, when I access dashboard, then layout adapts responsively

**Priority:** Low  
**Effort:** M  
**Dependencies:** US-013, US-014, US-015, US-016

**Technical Notes:**
- Drag-and-drop grid layout system
- Widget resize functionality
- User preference persistence
- Responsive breakpoints
- Dashboard state management

---

## US-019: Real-time Updates and Refresh

**As a** active trader  
**I want to** see real-time updates to my portfolio values  
**So that** I can make timely investment decisions

### Acceptance Criteria
- [ ] Given market is open, when I have dashboard open, then values update every 30 seconds
- [ ] Given prices change, when updates occur, then I see visual indicators of changes (green/red)
- [ ] Given I want immediate updates, when I click refresh, then latest data is fetched
- [ ] Given connection issues, when updates fail, then I see connection status indicator
- [ ] Given market is closed, when I view dashboard, then updates are paused until market open
- [ ] Given significant changes, when they occur, then I see notification of major moves

**Priority:** Medium  
**Effort:** M  
**Dependencies:** US-013

**Technical Notes:**
- WebSocket connections for real-time data
- Fallback to polling if WebSocket fails
- Visual change indicators with animations
- Connection status monitoring
- Market hours detection
- Notification system for significant changes
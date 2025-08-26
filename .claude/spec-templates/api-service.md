# [API Service Name] Specification

## Overview
[What this API provides]

## Endpoints

### Authentication
```
POST /auth/login
Body: { email, password }
Response: { token, user }
```

### Resource Management
```
GET /[resources]
Query: ?page=1&limit=10&sort=created_at
Response: { items: [], total, page }

POST /[resources]
Body: { ...resourceData }
Response: { id, ...resourceData }

PUT /[resources]/:id
Body: { ...updates }
Response: { ...updatedResource }

DELETE /[resources]/:id
Response: { success: true }
```

## Data Models

### [Model Name]
```json
{
  "id": "uuid",
  "field1": "type",
  "field2": "type",
  "created_at": "timestamp",
  "updated_at": "timestamp"
}
```

## Business Rules
- [Rule 1]: [Description]
- [Rule 2]: [Description]

## Error Handling
- 400: Invalid input
- 401: Unauthorized
- 404: Not found
- 500: Server error

## Performance Requirements
- Response time: < 200ms (p95)
- Throughput: 1000 req/s
- Availability: 99.9%

## Security
- Authentication: JWT
- Rate limiting: 100 req/min per IP
- Input validation: All inputs sanitized
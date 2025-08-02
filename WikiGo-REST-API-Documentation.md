# WikiGo REST API Documentation

## Overview

The WikiGo REST API provides programmatic access to the WikiGo multi-user wiki engine. This API allows you to manage words (wiki pages), search content, handle tags, and perform CRUD operations with proper authentication.

### Base URL
```
https://your-wikigo-instance.com/api/v1/
```

### API Version
Current version: `v1`

## Authentication

The WikiGo API uses Bearer token authentication. All API requests must include an `Authorization` header with a valid API token.

### Authentication Header
```
Authorization: Bearer <your-api-token>
```

### Getting an API Token
API tokens are managed through the WikiGo web interface:
1. Log in to your WikiGo instance
2. Navigate to Settings → API Tokens
3. Create a new token with a descriptive name
4. Copy the generated token (it will only be shown once)

### Authentication Errors
- **401 Unauthorized**: Invalid or missing API token
- **403 Forbidden**: Valid token but insufficient permissions

Example error response:
```json
{
  "error": "Unauthorized",
  "message": "Invalid or missing API token"
}
```

## Data Models

### Word Model
Represents a wiki page with rich text content and tagging capabilities.

```json
{
  "id": 123,
  "title": "Example Page",
  "slug": "example-page",
  "body": "Rich text content (plain text)",
  "body_html": "<p>Rich text content (HTML)</p>",
  "tags": ["documentation", "api"],
  "created_at": "2024-01-15T10:30:00Z",
  "updated_at": "2024-01-16T14:22:00Z",
  "url": "/example-page"
}
```

### Tag Model
Represents a tag with usage count.

```json
{
  "name": "documentation",
  "count": 15
}
```

### Pagination Model
Standard pagination information returned with list endpoints.

```json
{
  "current_page": 1,
  "total_pages": 5,
  "total_count": 125,
  "per_page": 25
}
```

## Endpoints

### Words

#### List Words
Retrieve a paginated list of words with optional filtering and sorting.

**Endpoint:** `GET /api/v1/words`

**Query Parameters:**
- `page` (integer, optional): Page number (default: 1)
- `per_page` (integer, optional): Items per page (default: 25, max: 100)
- `sort` (string, optional): Sort order
  - `created_at_asc` - Oldest first
  - `created_at_desc` - Newest first
  - `updated_at_asc` - Least recently updated first
  - `updated_at_desc` - Most recently updated first (default)
  - `title_asc` - Alphabetical by title
  - `title_desc` - Reverse alphabetical by title
- `q[title_cont]` (string, optional): Filter by title containing text
- `q[body_cont]` (string, optional): Filter by body containing text

**Example Request:**
```bash
curl -H "Authorization: Bearer your-token-here" \
     "https://your-wikigo-instance.com/api/v1/words?page=1&per_page=10&sort=title_asc"
```

**Example Response:**
```json
{
  "words": [
    {
      "id": 1,
      "title": "Home",
      "slug": "home",
      "tags": ["welcome"],
      "created_at": "2024-01-15T10:30:00Z",
      "updated_at": "2024-01-16T14:22:00Z",
      "url": "/home"
    }
  ],
  "pagination": {
    "current_page": 1,
    "total_pages": 5,
    "total_count": 125,
    "per_page": 10
  }
}
```

#### Get Word
Retrieve a specific word by ID or slug.

**Endpoint:** `GET /api/v1/words/:id`

**Parameters:**
- `id` (string, required): Word ID or slug

**Example Request:**
```bash
curl -H "Authorization: Bearer your-token-here" \
     "https://your-wikigo-instance.com/api/v1/words/home"
```

**Example Response:**
```json
{
  "word": {
    "id": 1,
    "title": "Home",
    "slug": "home",
    "body": "Welcome to WikiGo! This is the home page.",
    "body_html": "<p>Welcome to WikiGo! This is the home page.</p>",
    "tags": ["welcome", "documentation"],
    "created_at": "2024-01-15T10:30:00Z",
    "updated_at": "2024-01-16T14:22:00Z",
    "url": "/home"
  }
}
```

#### Create Word
Create a new word.

**Endpoint:** `POST /api/v1/words`

**Request Body:**
```json
{
  "word": {
    "title": "New Page",
    "body": "Content of the new page",
    "tag_list": "documentation,guide"
  }
}
```

**Parameters:**
- `word.title` (string, required): Title of the word (must be unique)
- `word.body` (string, optional): Rich text content
- `word.tag_list` (string, optional): Comma-separated list of tags

**Example Request:**
```bash
curl -X POST \
     -H "Authorization: Bearer your-token-here" \
     -H "Content-Type: application/json" \
     -d '{"word":{"title":"API Guide","body":"This is a guide for using the API","tag_list":"api,documentation"}}' \
     "https://your-wikigo-instance.com/api/v1/words"
```

**Example Response (201 Created):**
```json
{
  "word": {
    "id": 124,
    "title": "API Guide",
    "slug": "api-guide",
    "body": "This is a guide for using the API",
    "body_html": "<p>This is a guide for using the API</p>",
    "tags": ["api", "documentation"],
    "created_at": "2024-01-17T09:15:00Z",
    "updated_at": "2024-01-17T09:15:00Z",
    "url": "/api-guide"
  }
}
```

#### Update Word
Update an existing word.

**Endpoint:** `PUT /api/v1/words/:id` or `PATCH /api/v1/words/:id`

**Parameters:**
- `id` (string, required): Word ID or slug

**Request Body:**
```json
{
  "word": {
    "title": "Updated Title",
    "body": "Updated content",
    "tag_list": "updated,tags"
  }
}
```

**Example Request:**
```bash
curl -X PUT \
     -H "Authorization: Bearer your-token-here" \
     -H "Content-Type: application/json" \
     -d '{"word":{"body":"Updated API guide content","tag_list":"api,documentation,updated"}}' \
     "https://your-wikigo-instance.com/api/v1/words/api-guide"
```

**Example Response:**
```json
{
  "word": {
    "id": 124,
    "title": "API Guide",
    "slug": "api-guide",
    "body": "Updated API guide content",
    "body_html": "<p>Updated API guide content</p>",
    "tags": ["api", "documentation", "updated"],
    "created_at": "2024-01-17T09:15:00Z",
    "updated_at": "2024-01-17T10:30:00Z",
    "url": "/api-guide"
  }
}
```

#### Delete Word
Delete a word.

**Endpoint:** `DELETE /api/v1/words/:id`

**Parameters:**
- `id` (string, required): Word ID or slug

**Example Request:**
```bash
curl -X DELETE \
     -H "Authorization: Bearer your-token-here" \
     "https://your-wikigo-instance.com/api/v1/words/124"
```

**Example Response:**
```json
{
  "message": "Word deleted successfully"
}
```

### Search

#### Search Words
Search for words by title or content.

**Endpoint:** `GET /api/v1/words/search`

**Query Parameters:**
- `q` (string, required): Search query
- `page` (integer, optional): Page number (default: 1)
- `per_page` (integer, optional): Items per page (default: 25, max: 100)

**Example Request:**
```bash
curl -H "Authorization: Bearer your-token-here" \
     "https://your-wikigo-instance.com/api/v1/words/search?q=documentation&page=1&per_page=10"
```

**Example Response:**
```json
{
  "query": "documentation",
  "words": [
    {
      "id": 1,
      "title": "API Documentation",
      "slug": "api-documentation",
      "tags": ["api", "documentation"],
      "created_at": "2024-01-15T10:30:00Z",
      "updated_at": "2024-01-16T14:22:00Z",
      "url": "/api-documentation"
    }
  ],
  "pagination": {
    "current_page": 1,
    "total_pages": 3,
    "total_count": 28,
    "per_page": 10
  }
}
```

### Tags

#### List All Tags
Get all tags with their usage counts.

**Endpoint:** `GET /api/v1/words/tags`

**Example Request:**
```bash
curl -H "Authorization: Bearer your-token-here" \
     "https://your-wikigo-instance.com/api/v1/words/tags"
```

**Example Response:**
```json
{
  "tags": [
    {
      "name": "documentation",
      "count": 15
    },
    {
      "name": "api",
      "count": 8
    },
    {
      "name": "guide",
      "count": 12
    }
  ]
}
```

#### Get Words by Tag
Retrieve words that have a specific tag.

**Endpoint:** `GET /api/v1/words/tagged/:tag`

**Parameters:**
- `tag` (string, required): Tag name
- `page` (integer, optional): Page number (default: 1)
- `per_page` (integer, optional): Items per page (default: 25, max: 100)

**Example Request:**
```bash
curl -H "Authorization: Bearer your-token-here" \
     "https://your-wikigo-instance.com/api/v1/words/tagged/documentation?page=1&per_page=10"
```

**Example Response:**
```json
{
  "tag": "documentation",
  "words": [
    {
      "id": 1,
      "title": "API Documentation",
      "slug": "api-documentation",
      "tags": ["api", "documentation"],
      "created_at": "2024-01-15T10:30:00Z",
      "updated_at": "2024-01-16T14:22:00Z",
      "url": "/api-documentation"
    }
  ],
  "pagination": {
    "current_page": 1,
    "total_pages": 2,
    "total_count": 15,
    "per_page": 10
  }
}
```

## Error Handling

The API uses standard HTTP status codes and returns JSON error responses.

### HTTP Status Codes
- `200` - OK: Request successful
- `201` - Created: Resource created successfully
- `400` - Bad Request: Invalid request parameters
- `401` - Unauthorized: Authentication required or failed
- `403` - Forbidden: Access denied
- `404` - Not Found: Resource not found
- `422` - Unprocessable Entity: Validation failed
- `500` - Internal Server Error: Server error

### Error Response Format
```json
{
  "error": "Error Type",
  "message": "Human-readable error message",
  "details": ["Additional error details"]
}
```

### Common Error Examples

#### Validation Error (422)
```json
{
  "error": "Validation Failed",
  "message": "Could not create word",
  "details": [
    "Title can't be blank",
    "Title has already been taken"
  ]
}
```

#### Not Found Error (404)
```json
{
  "error": "Not Found",
  "message": "The requested resource was not found"
}
```

#### Bad Request Error (400)
```json
{
  "error": "Bad Request",
  "message": "Search query (q) parameter is required"
}
```

#### Parameter Missing Error (400)
```json
{
  "error": "Parameter Missing",
  "message": "param is missing or the value is empty: word"
}
```

## Rate Limiting

The API does not currently implement rate limiting, but this may be added in future versions. Monitor your usage and implement appropriate delays in your client applications.

## Pagination

All list endpoints support pagination with the following parameters:
- `page`: Page number (default: 1)
- `per_page`: Items per page (default: 25, maximum: 100)

Pagination information is included in the response:
```json
{
  "pagination": {
    "current_page": 1,
    "total_pages": 5,
    "total_count": 125,
    "per_page": 25
  }
}
```

## SDK Examples

### JavaScript/Node.js
```javascript
const axios = require('axios');

const api = axios.create({
  baseURL: 'https://your-wikigo-instance.com/api/v1/',
  headers: {
    'Authorization': 'Bearer your-token-here',
    'Content-Type': 'application/json'
  }
});

// Get all words
const words = await api.get('/words');

// Create a word
const newWord = await api.post('/words', {
  word: {
    title: 'New Page',
    body: 'Content here',
    tag_list: 'example,test'
  }
});

// Search words
const searchResults = await api.get('/words/search', {
  params: { q: 'documentation' }
});
```

### Python
```python
import requests

class WikiGoAPI:
    def __init__(self, base_url, token):
        self.base_url = base_url.rstrip('/') + '/api/v1'
        self.headers = {
            'Authorization': f'Bearer {token}',
            'Content-Type': 'application/json'
        }
    
    def get_words(self, page=1, per_page=25):
        response = requests.get(
            f'{self.base_url}/words',
            headers=self.headers,
            params={'page': page, 'per_page': per_page}
        )
        return response.json()
    
    def create_word(self, title, body='', tags=''):
        data = {
            'word': {
                'title': title,
                'body': body,
                'tag_list': tags
            }
        }
        response = requests.post(
            f'{self.base_url}/words',
            headers=self.headers,
            json=data
        )
        return response.json()

# Usage
api = WikiGoAPI('https://your-wikigo-instance.com', 'your-token-here')
words = api.get_words()
new_word = api.create_word('API Test', 'Testing the API', 'api,test')
```

### Ruby
```ruby
require 'net/http'
require 'json'

class WikiGoAPI
  def initialize(base_url, token)
    @base_url = "#{base_url.chomp('/')}/api/v1"
    @token = token
  end

  def get_words(page: 1, per_page: 25)
    uri = URI("#{@base_url}/words")
    uri.query = URI.encode_www_form(page: page, per_page: per_page)
    
    request = Net::HTTP::Get.new(uri)
    request['Authorization'] = "Bearer #{@token}"
    
    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
      http.request(request)
    end
    
    JSON.parse(response.body)
  end

  def create_word(title, body: '', tags: '')
    uri = URI("#{@base_url}/words")
    
    request = Net::HTTP::Post.new(uri)
    request['Authorization'] = "Bearer #{@token}"
    request['Content-Type'] = 'application/json'
    request.body = {
      word: {
        title: title,
        body: body,
        tag_list: tags
      }
    }.to_json
    
    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
      http.request(request)
    end
    
    JSON.parse(response.body)
  end
end

# Usage
api = WikiGoAPI.new('https://your-wikigo-instance.com', 'your-token-here')
words = api.get_words
new_word = api.create_word('Ruby API Test', body: 'Testing from Ruby', tags: 'ruby,api')
```

## Webhooks Integration

The WikiGo API automatically sends webhooks for word creation and updates. Webhook endpoints can be configured through the web interface at Settings → Webhooks.

Webhook payloads include:
- Event type (`create` or `update`)
- Word data
- User information
- Timestamp

## Best Practices

1. **Authentication**: Store API tokens securely and never expose them in client-side code
2. **Error Handling**: Always handle API errors gracefully in your applications
3. **Pagination**: Use pagination for large result sets to improve performance
4. **Rate Limiting**: Be considerate with API usage even though rate limiting is not currently enforced
5. **Validation**: Validate data before sending to the API to avoid unnecessary requests
6. **Caching**: Consider caching responses where appropriate to reduce API calls

## Support

For API support, please:
1. Check this documentation for common usage patterns
2. Review error messages for specific guidance
3. Check the WikiGo GitHub repository for known issues
4. Contact your WikiGo administrator for instance-specific questions

---

*Last updated: January 2024*
*API Version: v1*
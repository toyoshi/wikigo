# WikiGo

<img src='https://cloud.githubusercontent.com/assets/188394/19829766/528c7046-9e25-11e6-9271-0fa6916b770b.png' width='500'>

A simple, modern wiki engine built with Ruby on Rails 8. WikiGo automatically creates links between pages when you mention a page title anywhere in your content.

## Features

<img src='https://cloud.githubusercontent.com/assets/188394/19829747/d9d0b680-9e24-11e6-9d1d-40e20604f170.png' width='500'>

- **Auto-linking**: Page titles automatically become links throughout the wiki
- **Multi-user**: User authentication and role-based access
- **Rich text editing**: ActionText editor with Trix for content creation
- **Tagging system**: Organize content with tags
- **Version history**: Track changes with PaperTrail
- **Search functionality**: Find content across all pages
- **REST API**: Full API access for integrations and automation
- **Modern UI**: Bootstrap 5 responsive design
- **Rails 8 native**: Uses Solid Cache, Solid Queue, and Solid Cable

## Technology Stack

- **Ruby on Rails 8.0** - Modern web framework
- **Solid Trifecta** - Database-backed cache, queue, and cable (no Redis required)
- **ActionText** - Rich text editing with Trix editor
- **Bootstrap 5** - Responsive UI framework
- **SQLite/PostgreSQL** - Database options for development/production
- **Propshaft** - Rails 8 asset pipeline
- **Importmaps** - ES6 modules without bundling

## Quick Start

### Development

1. **Clone the repository**
   ```bash
   git clone https://github.com/toyoshi/wikigo.git
   cd wikigo
   ```

2. **Using Docker (Recommended)**
   ```bash
   docker-compose up
   ```
   Visit http://localhost:3000

3. **Local development**
   ```bash
   bundle install
   rails db:create db:migrate db:seed
   rails server
   ```

### Production Deployment

WikiGo is designed to be simple to deploy with minimal infrastructure requirements.

**Heroku Deployment**
[![Deploy](https://www.herokucdn.com/deploy/button.png)](https://heroku.com/deploy)

**Docker Deployment**
```bash
docker build -t wikigo .
docker run -p 3000:3000 wikigo
```

## Configuration

### Environment Variables

- `RAILS_ENV` - Set to `production` for production deployment
- `SECRET_KEY_BASE` - Rails secret key (auto-generated)
- `DATABASE_URL` - PostgreSQL connection string for production

### Optional Features

- **Image uploads**: Configure Active Storage for file attachments
- **Email notifications**: Set up Action Mailer for user notifications
- **Custom themes**: Modify Bootstrap variables in `app/assets/stylesheets/`

## How It Works

WikiGo's key feature is **automatic keyword linking**. When you create a page with a title like "Ruby on Rails", that exact phrase will automatically become a clickable link on any other page where it appears. This creates a natural, interconnected knowledge base without manual link management.

## REST API

WikiGo provides a comprehensive REST API for programmatic access to all wiki functionality. Perfect for integrations, automation, and building custom applications.

### API Features

- **Full CRUD operations** for wiki pages (Words)
- **Search and filtering** capabilities
- **Tag management** and filtering by tags
- **Bearer token authentication** for secure access
- **Pagination and sorting** for large datasets
- **Comprehensive error handling** with detailed responses

### Quick API Example

```bash
# Get all pages
curl -H "Authorization: Bearer YOUR_API_TOKEN" \
     https://your-wikigo-instance.com/api/v1/words

# Search pages
curl -H "Authorization: Bearer YOUR_API_TOKEN" \
     "https://your-wikigo-instance.com/api/v1/words/search?q=documentation"

# Create a new page
curl -X POST \
     -H "Authorization: Bearer YOUR_API_TOKEN" \
     -H "Content-Type: application/json" \
     -d '{"word":{"title":"API Guide","body":"Content here","tag_list":"api,guide"}}' \
     https://your-wikigo-instance.com/api/v1/words
```

### API Documentation

📖 **[Complete REST API Documentation](./WikiGo-REST-API-Documentation.md)**

- Authentication setup
- All available endpoints
- Request/response examples
- Error handling
- SDK examples in multiple languages

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## License

This project is available under the MIT License.

## Support

- Create an issue for bug reports or feature requests
- Check the wiki for documentation and examples
- Review the codebase - it's designed to be readable and educational
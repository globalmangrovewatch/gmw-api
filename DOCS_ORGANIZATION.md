# Documentation Organization

This file explains which documentation is public (in git) vs private (ignored by git).

## 📢 Public Documentation (Committed to Git)

These files are available to everyone:

### API/Usage Documentation
- **`README_NOTIFICATION.md`** - Basic API usage, examples, and configuration
  - How to send emails
  - Code examples
  - Component overview
  - No sensitive information

### Test Scripts
- **`test_notifications.rb`** - Test script for validating the notification system
  - Safe to share
  - No credentials

### Application Code
- All code in `app/`, `spec/`, `config/` (the actual implementation)
- This is the production-ready notification system

## 🔒 Private Documentation (Ignored by Git)

These files are for internal use only and are excluded via `.gitignore`:

### Deployment Guides (Root Level)
- `DEPLOYMENT_GUIDE.md` - Complete deployment reference
- `DEPLOYMENT_QUICKSTART.md` - Quick deployment guide
- `HEROKU_DASHBOARD_QUICK_GUIDE.md` - Heroku dashboard instructions
- `ENV_VARIABLES.md` - Environment variable examples (contains patterns)
- `docker-compose.production.yml` - Production Docker setup

### Summary/Context Files
- `FINAL_SUMMARY.md` - Implementation summary
- `IMPLEMENTATION_SUMMARY.md` - Technical details
- `NOTIFICATION_SYSTEM_README.md` - Master index
- `README_DEPLOYMENT_SUMMARY.md` - Deployment overview

### Detailed Documentation Folder (`docs/`)
The entire `docs/` folder is private and contains:
- `docs/DEPLOYMENT_CHECKLIST.md` - Step-by-step deployment
- `docs/HEROKU_DASHBOARD_DEPLOYMENT.md` - Heroku dashboard guide
- `docs/PRODUCTION_DEPLOYMENT.md` - Detailed production guide
- `docs/QUICK_START_TESTING.md` - Testing quick start
- `docs/TESTING_NOTIFICATIONS.md` - Comprehensive testing
- `docs/NOTIFICATION_SYSTEM.md` - Complete technical docs
- `docs/RESEND_SETUP_GUIDE.md` - Resend provider setup

## Why This Organization?

### Public Files Are:
✅ Essential for using the system  
✅ Safe to share (no credentials, no internal processes)  
✅ General API documentation  
✅ Code examples  

### Private Files Contain:
🔒 Internal deployment processes  
🔒 Provider-specific setup details  
🔒 Environment variable patterns  
🔒 Infrastructure details  
🔒 Internal testing procedures  
🔒 Company-specific workflows  

## For Team Members

All private documentation is available locally. Just don't commit these files:

```bash
# These are automatically ignored
DEPLOYMENT_*.md
ENV_VARIABLES.md
IMPLEMENTATION_SUMMARY.md
docs/

# Public files (will be committed)
README_NOTIFICATION.md
test_notifications.rb
app/
spec/
config/
```

## Accessing Private Docs

Private docs are on your local machine in:
- Project root: `*.md` files (except README_NOTIFICATION.md)
- `docs/` folder: All detailed guides

These files are preserved locally but won't be pushed to GitHub.

## For External Users

If you're using this notification system, check:
- **`README_NOTIFICATION.md`** - Complete API documentation
- **Code examples** - See `app/`, `spec/` for implementation details
- **Test script** - Run `test_notifications.rb` to validate setup

For deployment, you'll need to:
1. Configure SMTP provider (AWS SES, SendGrid, Resend, etc.)
2. Set environment variables
3. Set up Redis and Sidekiq
4. Follow standard Rails deployment practices

## Need the Full Documentation?

Contact the development team for access to internal deployment guides.

#!/bin/bash

set -e

BASE_URL="${BASE_URL:-https://mangrove-atlas-api-staging.herokuapp.com}"
EMAIL="${EMAIL:-leo.guercio@vizzuality.com}"
PASSWORD="${PASSWORD:-changeme123}"

echo "========================================"
echo "Notification Preferences API Test Script"
echo "========================================"
echo "Base URL: $BASE_URL"
echo "Email: $EMAIL"
echo ""
echo "Usage: EMAIL=user@example.com PASSWORD=secret BASE_URL=http://localhost:3000 ./scripts/test_notification_preferences.sh"
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_success() { echo -e "${GREEN}✓ $1${NC}"; }
print_error() { echo -e "${RED}✗ $1${NC}"; }
print_info() { echo -e "${YELLOW}→ $1${NC}"; }
print_header() { echo -e "${BLUE}== $1 ==${NC}"; }

# Step 1: Login
echo "----------------------------------------"
print_info "Step 1: Logging in..."
LOGIN_RESPONSE=$(curl -s -i -X POST "$BASE_URL/users/sign_in" \
  -H "Content-Type: application/json" \
  -d "{\"user\": {\"email\": \"$EMAIL\", \"password\": \"$PASSWORD\"}}")

TOKEN=$(echo "$LOGIN_RESPONSE" | grep -i "^authorization:" | sed 's/authorization: //i' | tr -d '\r')

if [ -z "$TOKEN" ]; then
  print_error "Login failed. Check credentials."
  echo "$LOGIN_RESPONSE"
  exit 1
fi

print_success "Logged in successfully"
echo "Token: ${TOKEN:0:50}..."
echo ""

# ============================================
# NOTIFICATION PREFERENCES TESTS
# ============================================
print_header "NOTIFICATION PREFERENCES"

# Step 2: Get current notification preferences
echo "----------------------------------------"
print_info "Step 2: Getting current notification preferences..."
PREFS=$(curl -s -X GET "$BASE_URL/api/v2/notification_preferences" \
  -H "Authorization: $TOKEN" \
  -H "Content-Type: application/json")
echo "$PREFS" | jq .
print_success "Retrieved notification preferences"
echo ""

# Step 3: Subscribe to newsletter
echo "----------------------------------------"
print_info "Step 3: Subscribing to newsletter..."
PREFS=$(curl -s -X PATCH "$BASE_URL/api/v2/notification_preferences" \
  -H "Authorization: $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"newsletter": true}')
echo "$PREFS" | jq .

NEWSLETTER_VALUE=$(echo "$PREFS" | jq -r '.data.newsletter')
if [ "$NEWSLETTER_VALUE" = "true" ]; then
  print_success "Newsletter subscription enabled"
else
  print_error "Failed to enable newsletter subscription"
fi
echo ""

# Step 4: Subscribe to platform updates
echo "----------------------------------------"
print_info "Step 4: Subscribing to platform updates..."
PREFS=$(curl -s -X PATCH "$BASE_URL/api/v2/notification_preferences" \
  -H "Authorization: $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"platform_updates": true}')
echo "$PREFS" | jq .

PLATFORM_VALUE=$(echo "$PREFS" | jq -r '.data.platform_updates')
if [ "$PLATFORM_VALUE" = "true" ]; then
  print_success "Platform updates subscription enabled"
else
  print_error "Failed to enable platform updates subscription"
fi
echo ""

# Step 5: Enable location alerts
echo "----------------------------------------"
print_info "Step 5: Enabling location alerts..."
PREFS=$(curl -s -X PATCH "$BASE_URL/api/v2/notification_preferences" \
  -H "Authorization: $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"location_alerts": true}')
echo "$PREFS" | jq .

LOCATION_ALERTS_VALUE=$(echo "$PREFS" | jq -r '.data.location_alerts')
if [ "$LOCATION_ALERTS_VALUE" = "true" ]; then
  print_success "Location alerts enabled"
else
  print_error "Failed to enable location alerts"
fi
echo ""

# Step 6: Update multiple preferences at once
echo "----------------------------------------"
print_info "Step 6: Updating multiple preferences at once (disable all)..."
PREFS=$(curl -s -X PATCH "$BASE_URL/api/v2/notification_preferences" \
  -H "Authorization: $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "location_alerts": false,
    "newsletter": false,
    "platform_updates": false
  }')
echo "$PREFS" | jq .

ALL_FALSE=$(echo "$PREFS" | jq -r '.data | .location_alerts == false and .newsletter == false and .platform_updates == false')
if [ "$ALL_FALSE" = "true" ]; then
  print_success "All preferences disabled successfully"
else
  print_error "Failed to disable all preferences"
fi
echo ""

# Step 7: Toggle location alerts
echo "----------------------------------------"
print_info "Step 7: Testing toggle_location_alerts (should enable)..."
PREFS=$(curl -s -X POST "$BASE_URL/api/v2/notification_preferences/toggle_location_alerts" \
  -H "Authorization: $TOKEN" \
  -H "Content-Type: application/json")
echo "$PREFS" | jq .

LOCATION_ALERTS_VALUE=$(echo "$PREFS" | jq -r '.data.location_alerts')
if [ "$LOCATION_ALERTS_VALUE" = "true" ]; then
  print_success "Location alerts toggled to: enabled"
else
  print_error "Toggle didn't work as expected"
fi
echo ""

# Step 8: Toggle again (should disable)
echo "----------------------------------------"
print_info "Step 8: Testing toggle_location_alerts again (should disable)..."
PREFS=$(curl -s -X POST "$BASE_URL/api/v2/notification_preferences/toggle_location_alerts" \
  -H "Authorization: $TOKEN" \
  -H "Content-Type: application/json")
echo "$PREFS" | jq .

LOCATION_ALERTS_VALUE=$(echo "$PREFS" | jq -r '.data.location_alerts')
if [ "$LOCATION_ALERTS_VALUE" = "false" ]; then
  print_success "Location alerts toggled to: disabled"
else
  print_error "Toggle didn't work as expected"
fi
echo ""

# ============================================
# USER LOCATIONS WITH ALERTS_ENABLED TESTS
# ============================================
print_header "USER LOCATIONS - ALERTS_ENABLED"

# Step 9: Create test locations for alerts testing
echo "----------------------------------------"
print_info "Step 9: Creating test locations for alerts testing..."

# First, clean up any existing locations
EXISTING=$(curl -s -X GET "$BASE_URL/api/v2/user_locations" \
  -H "Authorization: $TOKEN" \
  -H "Content-Type: application/json")
EXISTING_IDS=$(echo "$EXISTING" | jq -r '.data[].id // empty')
for ID in $EXISTING_IDS; do
  curl -s -X DELETE "$BASE_URL/api/v2/user_locations/$ID" \
    -H "Authorization: $TOKEN" \
    -H "Content-Type: application/json" > /dev/null
done
print_info "Cleaned up existing locations"

# Create location 1 with alerts enabled (default)
LOCATION_1=$(curl -s -X POST "$BASE_URL/api/v2/user_locations" \
  -H "Authorization: $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Location With Alerts ON",
    "custom_geometry": {
      "type": "Polygon",
      "coordinates": [[[100.0, 0.0], [100.0, 1.0], [101.0, 1.0], [101.0, 0.0], [100.0, 0.0]]]
    }
  }')
LOCATION_1_ID=$(echo "$LOCATION_1" | jq -r '.data.id')
LOCATION_1_ALERTS=$(echo "$LOCATION_1" | jq -r '.data.alerts_enabled')
echo "Location 1: ID=$LOCATION_1_ID, alerts_enabled=$LOCATION_1_ALERTS"

if [ "$LOCATION_1_ALERTS" = "true" ]; then
  print_success "Location created with alerts_enabled=true (default)"
else
  print_error "Expected alerts_enabled=true by default"
fi

# Create location 2 with alerts explicitly disabled
LOCATION_2=$(curl -s -X POST "$BASE_URL/api/v2/user_locations" \
  -H "Authorization: $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Location With Alerts OFF",
    "alerts_enabled": false,
    "custom_geometry": {
      "type": "Polygon",
      "coordinates": [[[102.0, 0.0], [102.0, 1.0], [103.0, 1.0], [103.0, 0.0], [102.0, 0.0]]]
    }
  }')
LOCATION_2_ID=$(echo "$LOCATION_2" | jq -r '.data.id')
LOCATION_2_ALERTS=$(echo "$LOCATION_2" | jq -r '.data.alerts_enabled')
echo "Location 2: ID=$LOCATION_2_ID, alerts_enabled=$LOCATION_2_ALERTS"

if [ "$LOCATION_2_ALERTS" = "false" ]; then
  print_success "Location created with alerts_enabled=false"
else
  print_error "Expected alerts_enabled=false"
fi
echo ""

# Step 10: List locations and check alerts_enabled field
echo "----------------------------------------"
print_info "Step 10: Listing locations with alerts_enabled status..."
curl -s -X GET "$BASE_URL/api/v2/user_locations" \
  -H "Authorization: $TOKEN" \
  -H "Content-Type: application/json" | jq '.data[] | {id, name, alerts_enabled}'
echo ""

# Step 11: Update a location to toggle alerts_enabled
echo "----------------------------------------"
print_info "Step 11: Updating location $LOCATION_1_ID to disable alerts..."
UPDATE_RESPONSE=$(curl -s -X PATCH "$BASE_URL/api/v2/user_locations/$LOCATION_1_ID" \
  -H "Authorization: $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"alerts_enabled": false}')
echo "$UPDATE_RESPONSE" | jq '{id: .data.id, name: .data.name, alerts_enabled: .data.alerts_enabled}'

UPDATED_ALERTS=$(echo "$UPDATE_RESPONSE" | jq -r '.data.alerts_enabled')
if [ "$UPDATED_ALERTS" = "false" ]; then
  print_success "Successfully disabled alerts for location"
else
  print_error "Failed to disable alerts"
fi
echo ""

# Step 12: Enable alerts again
echo "----------------------------------------"
print_info "Step 12: Re-enabling alerts for location $LOCATION_1_ID..."
UPDATE_RESPONSE=$(curl -s -X PATCH "$BASE_URL/api/v2/user_locations/$LOCATION_1_ID" \
  -H "Authorization: $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"alerts_enabled": true}')
echo "$UPDATE_RESPONSE" | jq '{id: .data.id, name: .data.name, alerts_enabled: .data.alerts_enabled}'

UPDATED_ALERTS=$(echo "$UPDATE_RESPONSE" | jq -r '.data.alerts_enabled')
if [ "$UPDATED_ALERTS" = "true" ]; then
  print_success "Successfully enabled alerts for location"
else
  print_error "Failed to enable alerts"
fi
echo ""

# Step 13: Test bulk toggle - disable all
echo "----------------------------------------"
print_info "Step 13: Bulk disabling alerts for ALL locations..."
BULK_RESPONSE=$(curl -s -X POST "$BASE_URL/api/v2/notification_preferences/bulk_toggle_location_alerts" \
  -H "Authorization: $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"enabled": false}')
echo "$BULK_RESPONSE" | jq '.data[] | {id, name, alerts_enabled}'

ALL_DISABLED=$(echo "$BULK_RESPONSE" | jq -r '[.data[].alerts_enabled] | all(. == false)')
if [ "$ALL_DISABLED" = "true" ]; then
  print_success "All locations have alerts disabled"
else
  print_error "Not all locations were disabled"
fi
echo ""

# Step 14: Test bulk toggle - enable all
echo "----------------------------------------"
print_info "Step 14: Bulk enabling alerts for ALL locations..."
BULK_RESPONSE=$(curl -s -X POST "$BASE_URL/api/v2/notification_preferences/bulk_toggle_location_alerts" \
  -H "Authorization: $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"enabled": true}')
echo "$BULK_RESPONSE" | jq '.data[] | {id, name, alerts_enabled}'

ALL_ENABLED=$(echo "$BULK_RESPONSE" | jq -r '[.data[].alerts_enabled] | all(. == true)')
if [ "$ALL_ENABLED" = "true" ]; then
  print_success "All locations have alerts enabled"
else
  print_error "Not all locations were enabled"
fi
echo ""

# Step 15: Test bulk toggle without parameter (should fail)
echo "----------------------------------------"
print_info "Step 15: Testing bulk toggle without 'enabled' parameter (should fail with 400)..."
BULK_RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "$BASE_URL/api/v2/notification_preferences/bulk_toggle_location_alerts" \
  -H "Authorization: $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{}')
HTTP_CODE=$(echo "$BULK_RESPONSE" | tail -n1)
RESPONSE_BODY=$(echo "$BULK_RESPONSE" | sed '$d')

if [ "$HTTP_CODE" = "400" ]; then
  print_success "Correctly rejected with 400 Bad Request"
  echo "$RESPONSE_BODY" | jq .
else
  print_error "Expected 400 but got $HTTP_CODE"
  echo "$RESPONSE_BODY"
fi
echo ""

# ============================================
# CLEANUP
# ============================================
print_header "CLEANUP"

echo "----------------------------------------"
print_info "Cleaning up test locations..."
for ID in $LOCATION_1_ID $LOCATION_2_ID; do
  if [ -n "$ID" ] && [ "$ID" != "null" ]; then
    curl -s -X DELETE "$BASE_URL/api/v2/user_locations/$ID" \
      -H "Authorization: $TOKEN" \
      -H "Content-Type: application/json" > /dev/null
    print_success "Deleted location $ID"
  fi
done

# Reset notification preferences to defaults
print_info "Resetting notification preferences to defaults..."
curl -s -X PATCH "$BASE_URL/api/v2/notification_preferences" \
  -H "Authorization: $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "location_alerts": false,
    "newsletter": false,
    "platform_updates": false
  }' > /dev/null
print_success "Notification preferences reset"
echo ""

echo "========================================"
print_success "All tests completed!"
echo "========================================"


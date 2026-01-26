#!/bin/bash

set -e

BASE_URL="${BASE_URL:-https://mangrove-atlas-api-staging.herokuapp.com}"
EMAIL="${EMAIL:-leo.guercio@vizzuality.com}"
PASSWORD="${PASSWORD:-changeme123}"

echo "========================================"
echo "User Locations API Test Script"
echo "========================================"
echo "Base URL: $BASE_URL"
echo "Email: $EMAIL"
echo ""
echo "Usage: EMAIL=user@example.com PASSWORD=secret BASE_URL=http://localhost:3000 ./scripts/test_user_locations.sh"
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_success() { echo -e "${GREEN}✓ $1${NC}"; }
print_error() { echo -e "${RED}✗ $1${NC}"; }
print_info() { echo -e "${YELLOW}→ $1${NC}"; }

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

# Step 2: List current locations (should be empty)
echo "----------------------------------------"
print_info "Step 2: Listing current user locations..."
curl -s -X GET "$BASE_URL/api/v2/user_locations" \
  -H "Authorization: $TOKEN" \
  -H "Content-Type: application/json" | jq .
echo ""

# Step 3: Create a system location (using location_id)
echo "----------------------------------------"
print_info "Step 3: Creating a system location (Indonesia - assuming location_id exists)..."

# First, get a valid location_id from the locations endpoint
LOCATION_RESPONSE=$(curl -s -X GET "$BASE_URL/api/v2/locations" \
  -H "Content-Type: application/json")
FIRST_LOCATION_ID=$(echo "$LOCATION_RESPONSE" | jq -r '.data[0].id // empty')
FIRST_LOCATION_NAME=$(echo "$LOCATION_RESPONSE" | jq -r '.data[0].name // "Unknown"')

if [ -z "$FIRST_LOCATION_ID" ]; then
  print_error "Could not get a system location ID"
  FIRST_LOCATION_ID=1
  FIRST_LOCATION_NAME="Test Location"
fi

print_info "Using system location: $FIRST_LOCATION_NAME (ID: $FIRST_LOCATION_ID)"

LOCATION_1=$(curl -s -X POST "$BASE_URL/api/v2/user_locations" \
  -H "Authorization: $TOKEN" \
  -H "Content-Type: application/json" \
  -d "{
    \"name\": \"My Favorite: $FIRST_LOCATION_NAME\",
    \"location_id\": $FIRST_LOCATION_ID
  }")
echo "$LOCATION_1" | jq .
LOCATION_1_ID=$(echo "$LOCATION_1" | jq -r '.data.id')
print_success "Created system location with ID: $LOCATION_1_ID"
echo ""

# Step 4: Create a custom geometry location
echo "----------------------------------------"
print_info "Step 4: Creating a custom geometry location (polygon)..."
LOCATION_2=$(curl -s -X POST "$BASE_URL/api/v2/user_locations" \
  -H "Authorization: $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "My Research Area - Amazon Delta",
    "custom_geometry": {
      "type": "Polygon",
      "coordinates": [[
        [-50.5, -0.5],
        [-50.5, -1.5],
        [-49.5, -1.5],
        [-49.5, -0.5],
        [-50.5, -0.5]
      ]]
    },
    "bounds": {
      "north": -0.5,
      "south": -1.5,
      "east": -49.5,
      "west": -50.5
    }
  }')
echo "$LOCATION_2" | jq .
LOCATION_2_ID=$(echo "$LOCATION_2" | jq -r '.data.id')
print_success "Created custom geometry location with ID: $LOCATION_2_ID"
echo ""

# Step 5: Create 3 more locations to reach the limit
echo "----------------------------------------"
print_info "Step 5: Creating 3 more custom locations to reach limit of 5..."

LOCATION_3=$(curl -s -X POST "$BASE_URL/api/v2/user_locations" \
  -H "Authorization: $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Mangrove Site Alpha",
    "custom_geometry": {
      "type": "Polygon",
      "coordinates": [[
        [103.8, 1.3],
        [103.8, 1.2],
        [103.9, 1.2],
        [103.9, 1.3],
        [103.8, 1.3]
      ]]
    }
  }')
LOCATION_3_ID=$(echo "$LOCATION_3" | jq -r '.data.id')
print_success "Created location 3 with ID: $LOCATION_3_ID"

LOCATION_4=$(curl -s -X POST "$BASE_URL/api/v2/user_locations" \
  -H "Authorization: $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Mangrove Site Beta",
    "custom_geometry": {
      "type": "Polygon",
      "coordinates": [[
        [110.5, -7.5],
        [110.5, -8.0],
        [111.0, -8.0],
        [111.0, -7.5],
        [110.5, -7.5]
      ]]
    }
  }')
LOCATION_4_ID=$(echo "$LOCATION_4" | jq -r '.data.id')
print_success "Created location 4 with ID: $LOCATION_4_ID"

LOCATION_5=$(curl -s -X POST "$BASE_URL/api/v2/user_locations" \
  -H "Authorization: $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Mangrove Site Gamma",
    "custom_geometry": {
      "type": "Polygon",
      "coordinates": [[
        [-80.2, 25.8],
        [-80.2, 25.7],
        [-80.1, 25.7],
        [-80.1, 25.8],
        [-80.2, 25.8]
      ]]
    }
  }')
LOCATION_5_ID=$(echo "$LOCATION_5" | jq -r '.data.id')
print_success "Created location 5 with ID: $LOCATION_5_ID"
echo ""

# Step 6: List all locations (should have 5)
echo "----------------------------------------"
print_info "Step 6: Listing all locations (should have 5)..."
curl -s -X GET "$BASE_URL/api/v2/user_locations" \
  -H "Authorization: $TOKEN" \
  -H "Content-Type: application/json" | jq .
echo ""

# Step 7: Try to create a 6th location (should fail)
echo "----------------------------------------"
print_info "Step 7: Attempting to create 6th location (should fail with 422)..."
LOCATION_6_RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "$BASE_URL/api/v2/user_locations" \
  -H "Authorization: $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "This Should Fail",
    "custom_geometry": {
      "type": "Polygon",
      "coordinates": [[[0, 0], [0, 1], [1, 1], [1, 0], [0, 0]]]
    }
  }')
HTTP_CODE=$(echo "$LOCATION_6_RESPONSE" | tail -n1)
RESPONSE_BODY=$(echo "$LOCATION_6_RESPONSE" | sed '$d')

if [ "$HTTP_CODE" = "422" ]; then
  print_success "Correctly rejected 6th location with 422"
  echo "$RESPONSE_BODY" | jq .
else
  print_error "Expected 422 but got $HTTP_CODE"
  echo "$RESPONSE_BODY"
fi
echo ""

# Step 8: Update a location
echo "----------------------------------------"
print_info "Step 8: Updating location $LOCATION_2_ID..."
UPDATE_RESPONSE=$(curl -s -X PATCH "$BASE_URL/api/v2/user_locations/$LOCATION_2_ID" \
  -H "Authorization: $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Updated: Amazon Delta Research Zone",
    "bounds": {
      "north": -0.3,
      "south": -1.7,
      "east": -49.3,
      "west": -50.7
    }
  }')
echo "$UPDATE_RESPONSE" | jq .
print_success "Location updated"
echo ""

# Step 9: Get a single location
echo "----------------------------------------"
print_info "Step 9: Getting single location $LOCATION_1_ID..."
curl -s -X GET "$BASE_URL/api/v2/user_locations/$LOCATION_1_ID" \
  -H "Authorization: $TOKEN" \
  -H "Content-Type: application/json" | jq .
echo ""

# Step 10: Reorder locations
echo "----------------------------------------"
print_info "Step 10: Reordering locations..."
REORDER_RESPONSE=$(curl -s -X PATCH "$BASE_URL/api/v2/user_locations/reorder" \
  -H "Authorization: $TOKEN" \
  -H "Content-Type: application/json" \
  -d "{
    \"positions\": [$LOCATION_5_ID, $LOCATION_4_ID, $LOCATION_3_ID, $LOCATION_2_ID, $LOCATION_1_ID]
  }")
echo "$REORDER_RESPONSE" | jq '.data[] | {id, name, position}'
print_success "Locations reordered"
echo ""

# Step 11: Delete a location
echo "----------------------------------------"
print_info "Step 11: Deleting location $LOCATION_5_ID..."
DELETE_RESPONSE=$(curl -s -w "%{http_code}" -X DELETE "$BASE_URL/api/v2/user_locations/$LOCATION_5_ID" \
  -H "Authorization: $TOKEN" \
  -H "Content-Type: application/json")

if [ "$DELETE_RESPONSE" = "204" ]; then
  print_success "Location deleted successfully (204 No Content)"
else
  print_error "Unexpected response: $DELETE_RESPONSE"
fi
echo ""

# Step 12: Verify we can now add a new location
echo "----------------------------------------"
print_info "Step 12: Verifying we can add a new location after deletion..."
NEW_LOCATION=$(curl -s -X POST "$BASE_URL/api/v2/user_locations" \
  -H "Authorization: $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "New Location After Delete",
    "custom_geometry": {
      "type": "Polygon",
      "coordinates": [[[120.0, -5.0], [120.0, -6.0], [121.0, -6.0], [121.0, -5.0], [120.0, -5.0]]]
    }
  }')
NEW_LOCATION_ID=$(echo "$NEW_LOCATION" | jq -r '.data.id')
if [ "$NEW_LOCATION_ID" != "null" ] && [ -n "$NEW_LOCATION_ID" ]; then
  print_success "Successfully created new location with ID: $NEW_LOCATION_ID"
else
  print_error "Failed to create new location"
  echo "$NEW_LOCATION" | jq .
fi
echo ""

# Step 13: Final listing
echo "----------------------------------------"
print_info "Step 13: Final listing of all user locations..."
curl -s -X GET "$BASE_URL/api/v2/user_locations" \
  -H "Authorization: $TOKEN" \
  -H "Content-Type: application/json" | jq .
echo ""

# Cleanup (optional - uncomment to delete all test locations)
echo "----------------------------------------"
print_info "Cleanup: Deleting all test locations..."
for ID in $LOCATION_1_ID $LOCATION_2_ID $LOCATION_3_ID $LOCATION_4_ID $NEW_LOCATION_ID; do
  if [ -n "$ID" ] && [ "$ID" != "null" ]; then
    curl -s -X DELETE "$BASE_URL/api/v2/user_locations/$ID" \
      -H "Authorization: $TOKEN" \
      -H "Content-Type: application/json"
    print_success "Deleted location $ID"
  fi
done
echo ""

echo "========================================"
print_success "All tests completed!"
echo "========================================"


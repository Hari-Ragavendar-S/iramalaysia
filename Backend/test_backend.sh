#!/bin/bash

# Irama1Asia - Backend Test Script
# Quick test to verify backend is working

echo "═══════════════════════════════════════════════════════"
echo "🧪 Testing Irama1Asia Backend"
echo "═══════════════════════════════════════════════════════"
echo ""

# Get domain from user
read -p "Enter your domain (or press Enter for localhost): " DOMAIN
if [ -z "$DOMAIN" ]; then
    BASE_URL="http://127.0.0.1:8000"
    echo "Testing local backend..."
else
    BASE_URL="https://$DOMAIN"
    echo "Testing $BASE_URL..."
fi

echo ""

# Test 1: Health Check
echo "1️⃣ Testing Health Endpoint..."
HEALTH=$(curl -s -o /dev/null -w "%{http_code}" $BASE_URL/health)
if [ "$HEALTH" = "200" ]; then
    echo "   ✅ Health check passed"
    curl -s $BASE_URL/health | python3 -m json.tool
else
    echo "   ❌ Health check failed (HTTP $HEALTH)"
fi
echo ""

# Test 2: API Root
echo "2️⃣ Testing API Root..."
ROOT=$(curl -s -o /dev/null -w "%{http_code}" $BASE_URL/)
if [ "$ROOT" = "200" ]; then
    echo "   ✅ API root accessible"
else
    echo "   ❌ API root failed (HTTP $ROOT)"
fi
echo ""

# Test 3: API Documentation
echo "3️⃣ Testing API Documentation..."
DOCS=$(curl -s -o /dev/null -w "%{http_code}" $BASE_URL/api/v1/docs)
if [ "$DOCS" = "200" ]; then
    echo "   ✅ API docs accessible"
    echo "   📚 Visit: $BASE_URL/api/v1/docs"
else
    echo "   ❌ API docs failed (HTTP $DOCS)"
fi
echo ""

# Test 4: Locations Endpoint
echo "4️⃣ Testing Locations Endpoint..."
LOCATIONS=$(curl -s -o /dev/null -w "%{http_code}" $BASE_URL/api/v1/locations/states)
if [ "$LOCATIONS" = "200" ]; then
    echo "   ✅ Locations endpoint working"
    echo "   States available:"
    curl -s $BASE_URL/api/v1/locations/states | python3 -m json.tool | head -20
else
    echo "   ❌ Locations endpoint failed (HTTP $LOCATIONS)"
fi
echo ""

# Test 5: SSL Certificate (if HTTPS)
if [[ $BASE_URL == https* ]]; then
    echo "5️⃣ Testing SSL Certificate..."
    SSL_EXPIRY=$(echo | openssl s_client -servername $DOMAIN -connect $DOMAIN:443 2>/dev/null | openssl x509 -noout -dates 2>/dev/null | grep "notAfter")
    if [ $? -eq 0 ]; then
        echo "   ✅ SSL certificate valid"
        echo "   $SSL_EXPIRY"
    else
        echo "   ❌ SSL certificate check failed"
    fi
    echo ""
fi

# Summary
echo "═══════════════════════════════════════════════════════"
echo "📊 Test Summary"
echo "═══════════════════════════════════════════════════════"
echo ""

TOTAL=4
PASSED=0

[ "$HEALTH" = "200" ] && ((PASSED++))
[ "$ROOT" = "200" ] && ((PASSED++))
[ "$DOCS" = "200" ] && ((PASSED++))
[ "$LOCATIONS" = "200" ] && ((PASSED++))

echo "Tests Passed: $PASSED/$TOTAL"
echo ""

if [ $PASSED -eq $TOTAL ]; then
    echo "✅ All tests passed! Backend is working correctly."
else
    echo "⚠️  Some tests failed. Check the logs above."
fi

echo ""
echo "═══════════════════════════════════════════════════════"

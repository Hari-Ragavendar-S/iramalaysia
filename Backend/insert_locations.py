#!/usr/bin/env python3
"""
Insert busking locations data into the database
"""

import asyncio
import sys
from pathlib import Path

# Add the app directory to Python path
sys.path.append(str(Path(__file__).parent))

from app.core.database import AsyncSessionLocal
from app.models.location import BuskingLocation

# Location data exactly as provided
LOCATION_DATA = [
    {
        "location_name": "Suria KLCC",
        "location_type": "Shopping Mall",
        "state": "Kuala Lumpur",
        "city": "Kuala Lumpur",
        "full_address": "Jalan Ampang, 50088 Kuala Lumpur",
        "indoor_outdoor": "Indoor",
        "busking_area_description": "Concourse level near main entrance",
        "crowd_type": "Tourists, families, office workers",
        "suitable_for_busking": "Yes",
        "remarks": "High foot traffic"
    },
    {
        "location_name": "Pavilion Kuala Lumpur",
        "location_type": "Shopping Mall",
        "state": "Kuala Lumpur",
        "city": "Bukit Bintang",
        "full_address": "168 Jalan Bukit Bintang, 55100 Kuala Lumpur",
        "indoor_outdoor": "Indoor",
        "busking_area_description": "Main atrium area",
        "crowd_type": "Shoppers, tourists, youths",
        "suitable_for_busking": "Yes",
        "remarks": "Premium crowd"
    },
    {
        "location_name": "Mid Valley Megamall",
        "location_type": "Shopping Mall",
        "state": "Kuala Lumpur",
        "city": "Mid Valley City",
        "full_address": "Lingkaran Syed Putra, 59200 Kuala Lumpur",
        "indoor_outdoor": "Indoor",
        "busking_area_description": "Central court",
        "crowd_type": "Families, students, office workers",
        "suitable_for_busking": "Yes",
        "remarks": "Very busy weekends"
    },
    {
        "location_name": "Sunway Pyramid",
        "location_type": "Shopping Mall",
        "state": "Selangor",
        "city": "Bandar Sunway",
        "full_address": "3 Jalan PJS 11/15, 46150 Petaling Jaya",
        "indoor_outdoor": "Indoor",
        "busking_area_description": "Main ice rink concourse",
        "crowd_type": "Youths, families, tourists",
        "suitable_for_busking": "Yes",
        "remarks": "Tourist hotspot"
    },
    {
        "location_name": "1 Utama Shopping Centre",
        "location_type": "Shopping Mall",
        "state": "Selangor",
        "city": "Petaling Jaya",
        "full_address": "1 Lebuh Bandar Utama, 47800 Petaling Jaya",
        "indoor_outdoor": "Indoor",
        "busking_area_description": "Old Wing main hall",
        "crowd_type": "Mixed crowd, families",
        "suitable_for_busking": "Yes",
        "remarks": "Large mall"
    },
    {
        "location_name": "IOI City Mall",
        "location_type": "Shopping Mall",
        "state": "Selangor",
        "city": "Putrajaya",
        "full_address": "Lebuh IRC, 62502 Putrajaya",
        "indoor_outdoor": "Indoor",
        "busking_area_description": "Central atrium",
        "crowd_type": "Families, tourists",
        "suitable_for_busking": "Yes",
        "remarks": "Wide open space"
    },
    {
        "location_name": "AEON Mall Shah Alam",
        "location_type": "Shopping Mall",
        "state": "Selangor",
        "city": "Shah Alam",
        "full_address": "Jalan Akuatik 13/64, 40100 Shah Alam",
        "indoor_outdoor": "Indoor",
        "busking_area_description": "Main entrance lobby",
        "crowd_type": "Local shoppers",
        "suitable_for_busking": "Yes",
        "remarks": "Family crowd"
    },
    {
        "location_name": "Gurney Plaza",
        "location_type": "Shopping Mall",
        "state": "Pulau Pinang",
        "city": "George Town",
        "full_address": "Persiaran Gurney, 10250 George Town",
        "indoor_outdoor": "Indoor",
        "busking_area_description": "Ground floor atrium",
        "crowd_type": "Tourists, locals",
        "suitable_for_busking": "Yes",
        "remarks": "Tourist area"
    },
    {
        "location_name": "Queensbay Mall",
        "location_type": "Shopping Mall",
        "state": "Pulau Pinang",
        "city": "Bayan Lepas",
        "full_address": "100 Persiaran Bayan Indah, 11900 Bayan Lepas",
        "indoor_outdoor": "Indoor",
        "busking_area_description": "Central concourse",
        "crowd_type": "Families, youths",
        "suitable_for_busking": "Yes",
        "remarks": "Large open area"
    },
    {
        "location_name": "Ipoh Parade",
        "location_type": "Shopping Mall",
        "state": "Perak",
        "city": "Ipoh",
        "full_address": "105 Jalan Sultan Abdul Jalil, 30350 Ipoh",
        "indoor_outdoor": "Indoor",
        "busking_area_description": "Main atrium",
        "crowd_type": "Families, youths",
        "suitable_for_busking": "Yes",
        "remarks": "Central location"
    },
    {
        "location_name": "AEON Mall Taiping",
        "location_type": "Shopping Mall",
        "state": "Perak",
        "city": "Taiping",
        "full_address": "Jalan Kamunting, 34000 Taiping",
        "indoor_outdoor": "Indoor",
        "busking_area_description": "Main entrance area",
        "crowd_type": "Local families",
        "suitable_for_busking": "Yes",
        "remarks": "Community mall"
    },
    {
        "location_name": "Paradigm Mall Johor Bahru",
        "location_type": "Shopping Mall",
        "state": "Johor",
        "city": "Johor Bahru",
        "full_address": "Jalan Skudai, 81200 Johor Bahru",
        "indoor_outdoor": "Indoor",
        "busking_area_description": "Main atrium",
        "crowd_type": "Families, tourists",
        "suitable_for_busking": "Yes",
        "remarks": "High traffic"
    },
    {
        "location_name": "KSL City Mall",
        "location_type": "Shopping Mall",
        "state": "Johor",
        "city": "Johor Bahru",
        "full_address": "Jalan Seladang, 80250 Johor Bahru",
        "indoor_outdoor": "Indoor",
        "busking_area_description": "Ground floor concourse",
        "crowd_type": "Tourists, shoppers",
        "suitable_for_busking": "Yes",
        "remarks": "Near hotel"
    },
    {
        "location_name": "Mahkota Parade",
        "location_type": "Shopping Mall",
        "state": "Melaka",
        "city": "Bandar Hilir",
        "full_address": "Jalan Merdeka, 75000 Melaka",
        "indoor_outdoor": "Indoor",
        "busking_area_description": "Central atrium",
        "crowd_type": "Tourists, families",
        "suitable_for_busking": "Yes",
        "remarks": "Tourist zone"
    },
    {
        "location_name": "AEON Mall Seremban 2",
        "location_type": "Shopping Mall",
        "state": "Negeri Sembilan",
        "city": "Seremban",
        "full_address": "Jalan S2 B23, 70300 Seremban",
        "indoor_outdoor": "Indoor",
        "busking_area_description": "Main lobby",
        "crowd_type": "Local families",
        "suitable_for_busking": "Yes",
        "remarks": "Residential area"
    },
    {
        "location_name": "Aman Central",
        "location_type": "Shopping Mall",
        "state": "Kedah",
        "city": "Alor Setar",
        "full_address": "Darul Aman Highway, 05100 Alor Setar",
        "indoor_outdoor": "Indoor",
        "busking_area_description": "Main atrium",
        "crowd_type": "Youths, families",
        "suitable_for_busking": "Yes",
        "remarks": "City mall"
    },
    {
        "location_name": "Central Square Sungai Petani",
        "location_type": "Shopping Mall",
        "state": "Kedah",
        "city": "Sungai Petani",
        "full_address": "Jalan Kampung Baru, 08000 Sungai Petani",
        "indoor_outdoor": "Indoor",
        "busking_area_description": "Entrance concourse",
        "crowd_type": "Local shoppers",
        "suitable_for_busking": "Yes",
        "remarks": "Local crowd"
    },
    {
        "location_name": "Mydin Mall Kota Bharu",
        "location_type": "Shopping Mall",
        "state": "Kelantan",
        "city": "Kota Bharu",
        "full_address": "Jalan Sultan Ibrahim, 15050 Kota Bharu",
        "indoor_outdoor": "Indoor",
        "busking_area_description": "Main entrance",
        "crowd_type": "Local families",
        "suitable_for_busking": "Yes",
        "remarks": "Budget shoppers"
    },
    {
        "location_name": "KTCC Mall",
        "location_type": "Shopping Mall",
        "state": "Terengganu",
        "city": "Kuala Terengganu",
        "full_address": "Jalan Gong Badak, 21300 Kuala Terengganu",
        "indoor_outdoor": "Indoor",
        "busking_area_description": "Ground floor atrium",
        "crowd_type": "Families, youths",
        "suitable_for_busking": "Yes",
        "remarks": "Student crowd"
    },
    {
        "location_name": "East Coast Mall",
        "location_type": "Shopping Mall",
        "state": "Pahang",
        "city": "Kuantan",
        "full_address": "Jalan Putra Square, 25200 Kuantan",
        "indoor_outdoor": "Indoor",
        "busking_area_description": "Central court",
        "crowd_type": "Families, shoppers",
        "suitable_for_busking": "Yes",
        "remarks": "Main city mall"
    },
    {
        "location_name": "Imago Shopping Mall",
        "location_type": "Shopping Mall",
        "state": "Sabah",
        "city": "Kota Kinabalu",
        "full_address": "Jalan Coastal, 88000 Kota Kinabalu",
        "indoor_outdoor": "Indoor",
        "busking_area_description": "Main atrium",
        "crowd_type": "Tourists, locals",
        "suitable_for_busking": "Yes",
        "remarks": "Waterfront mall"
    },
    {
        "location_name": "Suria Sabah",
        "location_type": "Shopping Mall",
        "state": "Sabah",
        "city": "Kota Kinabalu",
        "full_address": "Jalan Tun Fuad Stephens, 88000 Kota Kinabalu",
        "indoor_outdoor": "Indoor",
        "busking_area_description": "Waterfront entrance",
        "crowd_type": "Tourists",
        "suitable_for_busking": "Yes",
        "remarks": "Tourist heavy"
    },
    {
        "location_name": "The Spring Shopping Mall",
        "location_type": "Shopping Mall",
        "state": "Sarawak",
        "city": "Kuching",
        "full_address": "Jalan Simpang Tiga, 93350 Kuching",
        "indoor_outdoor": "Indoor",
        "busking_area_description": "Central concourse",
        "crowd_type": "Families, youths",
        "suitable_for_busking": "Yes",
        "remarks": "Popular mall"
    },
    {
        "location_name": "Vivacity Megamall",
        "location_type": "Shopping Mall",
        "state": "Sarawak",
        "city": "Kuching",
        "full_address": "Jalan Wan Alwi, 93350 Kuching",
        "indoor_outdoor": "Indoor",
        "busking_area_description": "Main atrium",
        "crowd_type": "Youths, shoppers",
        "suitable_for_busking": "Yes",
        "remarks": "Modern mall"
    },
    {
        "location_name": "Financial Park Labuan",
        "location_type": "Shopping Mall",
        "state": "Labuan",
        "city": "Victoria",
        "full_address": "Jalan Merdeka, 87000 Labuan",
        "indoor_outdoor": "Indoor",
        "busking_area_description": "Ground floor lobby",
        "crowd_type": "Local community",
        "suitable_for_busking": "Yes",
        "remarks": "Business area"
    }
]

async def insert_locations():
    """Insert location data into database"""
    print("🏢 Inserting busking locations data...")
    
    async with AsyncSessionLocal() as db:
        try:
            # Check if locations already exist
            from sqlalchemy import select, func
            result = await db.execute(select(func.count(BuskingLocation.id)))
            existing_count = result.scalar()
            
            if existing_count > 0:
                print(f"ℹ️  Found {existing_count} existing locations. Skipping insertion.")
                return
            
            # Insert all locations
            for location_data in LOCATION_DATA:
                location = BuskingLocation(**location_data)
                db.add(location)
            
            await db.commit()
            print(f"✅ Successfully inserted {len(LOCATION_DATA)} busking locations!")
            
            # Print summary by state
            result = await db.execute(
                select(BuskingLocation.state, func.count(BuskingLocation.id))
                .group_by(BuskingLocation.state)
                .order_by(BuskingLocation.state)
            )
            state_counts = result.all()
            
            print("\n📊 Locations by state:")
            for state, count in state_counts:
                print(f"   {state}: {count} locations")
            
        except Exception as e:
            print(f"❌ Error inserting locations: {str(e)}")
            await db.rollback()
            raise

if __name__ == "__main__":
    asyncio.run(insert_locations())
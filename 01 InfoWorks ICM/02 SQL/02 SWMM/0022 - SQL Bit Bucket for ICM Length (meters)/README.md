# Conduit Length Distribution Script for InfoWorks ICM

This SQL script calculates the distribution of conduit lengths in an InfoWorks ICM model network. It groups conduits into buckets based on their lengths and counts the number of conduits in each bucket.

## How it Works

The script operates in two main steps:

1. **Bucket Definition**: The script defines a list of buckets, which are the upper bounds for each length category. The buckets are defined in meters and range from 2 meters to 1500 meters.

2. **Length Distribution Calculation**: The script selects the count of conduits grouped by their length category. The length category is determined by the `RINDEX` function, which finds the rightmost position of the conduit length in the list of buckets.

## Usage

To use this script, simply run it in the context of an open network in InfoWorks ICM. The script will automatically calculate the distribution of conduit lengths and group them into the defined buckets.
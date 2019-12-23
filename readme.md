# krp_business
A light-weight business ownership resource for FiveM.

![Screenshot of krp_business](https://raw.githubusercontent.com/dremin/krp_business/master/screenshot.jpg)

## Requirements
- ESX
- cron
- gcphone
- mysql-async

## Installation
1. Import `krp_business.sql` to your FiveM database
2. Add this resource to your `resources` folder and `server.cfg`

## Usage
Businesses defined in the `businesses` database table will be shown at the corresponding location in the game and on the map.

If a business is owned by a player, their name and `gcphone` phone number will be displayed. The player will receive a daily payout (paid out at 00:00 and 12:00 UTC by default) as defined on the business. The business owner will see a marker below the business information. When the owner enters the marker, they will have the option to sell the business for a percentage of the original purchase price.

If a business is not owned by any player, it will also have a marker below it. When a player enters the marker, they will have the option to purchase the business for the listed price. If the player purchases the business, they can also give it a custom name.
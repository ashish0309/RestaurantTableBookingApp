# RestaurantTableBookingApp
A simple Restaurant Table booking app using Firebase realtime Database, where a receptionist user can add customers to waiting queue, assign tables to customers on first come basis.

## Scenarios covered in the App
### Receptionist Login
* On the top you can see “Waiting table counter”. The customer can be added to the waiting queue only when the message on the top says “All Tables are occupied”.
* “Add customer to Waiting Queue” will only be enabled when Name and 10 digit phone number is entered.
* Already occupied tables can be released clicking on “Tap to release a table”.
* Once a table is released, in the “Waiting Customers” screen, Table could be reserved for the first customer from the waiting list.
* Customers can be searched via “Search Waiting Customer”.
* When waiting queue is empty, a customer can be assigned a Table by selecting “Assign Table to customer” directly without entering   customer information.

### Customer Login

* Can be logged in only with phone number.
* Can view the real time waiting while using the app.
* Will see a message of Table assignment if the app is on.

### Implementation Logic

* For simplicity, the project assumes the default behavior of Firebase is to ensure the data is stored based on created date. Hence, no timestamp data is saved explicitly at the Customer Waiting model level.
* For simplicity, the Project assumes there will be only one receptionist at a time entering the Booking Tables' data, so concurrency issues have not been taken into account. Transaction operation can be used to ensure concurrency, if need be.
* App behavior is not tested when there is no network. Ideally it should work fine, since firebase stores the data locally and then syncs when there is network. Data corruption may be possible.
* Anonymous login is used for authentication.
* For simplicity, following thing is  done.
To enable 2 different logins, login type of the user is saved in Userdefaults, so that, while testing user can switch to different login easily after deleting the app.
For changing the user login (receptionist or customer), app needs to be deleted and reinstalled.

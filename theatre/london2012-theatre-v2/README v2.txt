This data set includes theatre ticket sales for performances in the year 2012. To ensure 
commercial confidentiality, theatres have been grouped into "Theatre Zones" which contain 
3 or more theatres. Customers have also be grouped into Output Areas (OA11).

Theatres v2.csv:
A list of London theatres, their geographical information and assigned theatre zone. An 
undisclosed selection of theatres have been included in the study to protect commercial 
confidentiality. See table:

Zone:       Number of included theatres: 	Total in zone:         Zone descriptions:
Zone 1      4	                            18                     Roughly West End & Soho
Zone 2      6	                            26                     Roughly Covent Garden &
                                                                    Holborn
Zone 3      4	                            6                      East London
Zone 4	    3	                            7                      South East London
Zone 5	    12	                            16                     West & South West London

Columns -
Theatre:                    The theatre
Zone:                       The zone the theatre has been assigned too
Postcode:                   Postcode of the theatre
Lat, Long:                  GPS coordinates


Sales Data.csv:
Ticket sold to customers who reside in a Output Area (OA11) for a theatre performance on a
specified day. Each row also supplies date of the sale. Therefore there are four keys for
each row: output area of the customer (OA11), zone of the theatre (theatre_zone), date 
of the performance (performance_date) and sale date (sale_date).

The following filters have been applied:
- Performances that took place in 2012
- Consumer sales only (e.g. box office/walk-ins and agent sales were removed)
- Sales where the address of the customer is unknown have been removed
- A minimum of 100 seats sold for a performance
- A minimum of 3 performances taking place each day in each theatre Zone to be included

Columns -
sale_date:                  The date the ticket(s) was sold    
performance_date:           The date of the performance
OA11:                       The output area of the customer's address
unique_customer_bookings:   The number of customers who made bookings
total_spend:                The total spent on the tickets 
total_tickets:              The total number of tickets sold
total_venues:               The number of venues the performances are held at
theatre_zone:               The zone the theatre(s) resides in

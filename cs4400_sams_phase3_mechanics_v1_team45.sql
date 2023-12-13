-- CS4400: Introduction to Database Systems: Tuesday, September 12, 2023
-- Simple Airline Management System Course Project Mechanics [TEMPLATE] (v0)
-- Views, Functions & Stored Procedures

-- FINAL FINAL SUBMISSION

/* This is a standard preamble for most of our scripts.  The intent is to establish
a consistent environment for the database behavior. */
set global transaction isolation level serializable;
set global SQL_MODE = 'ANSI,TRADITIONAL';
set names utf8mb4;
set SQL_SAFE_UPDATES = 0;

set @thisDatabase = 'flight_tracking';
use flight_tracking;
-- -----------------------------------------------------------------------------
-- stored procedures and views
-- -----------------------------------------------------------------------------
/* Standard Procedure: If one or more of the necessary conditions for a procedure to
be executed is false, then simply have the procedure halt execution without changing
the database state. Do NOT display any error messages, etc. */

-- [_] supporting functions, views and stored procedures
-- -----------------------------------------------------------------------------
/* Helpful library capabilities to simplify the implementation of the required
views and procedures. */
-- -----------------------------------------------------------------------------
drop function if exists leg_time;
delimiter //
create function leg_time (ip_distance integer, ip_speed integer)
	returns time reads sql data
begin
	declare total_time decimal(10,2);
    declare hours, minutes integer default 0;
    set total_time = ip_distance / ip_speed;
    set hours = truncate(total_time, 0);
    set minutes = truncate((total_time - hours) * 60, 0);
    return maketime(hours, minutes, 0);
end //
delimiter ;

-- [1] add_airplane()
-- -----------------------------------------------------------------------------
/* This stored procedure creates a new airplane.  A new airplane must be sponsored
by an existing airline, and must have a unique tail number for that airline.
username.  An airplane must also have a non-zero seat capacity and speed. An airplane
might also have other factors depending on it's type, like skids or some number
of engines.  Finally, an airplane must have a new and database-wide unique location
since it will be used to carry passengers. */
-- -----------------------------------------------------------------------------
drop procedure if exists add_airplane;
delimiter //
create procedure add_airplane (in ip_airlineID varchar(50), in ip_tail_num varchar(50),
	in ip_seat_capacity integer, in ip_speed integer, in ip_locationID varchar(50),
    in ip_plane_type varchar(100), in ip_skids boolean, in ip_propellers integer,
    in ip_jet_engines integer)
sp_main: begin
	if ip_airlineID in (select airlineID from airline)
    and ip_tail_num not in (select tail_num from airplane where airlineID = ip_airlineID)
    and ip_seat_capacity > 0
    and ip_speed > 0 then
		if ip_locationID is NOT NULL and ip_locationID not in (select locationID from location) then
			insert into location values (ip_locationID);
            insert into airplane values 
            (ip_airlineID, ip_tail_num, ip_seat_capacity, ip_speed, ip_locationID, ip_plane_type, ip_skids, ip_propellers, ip_jet_engines);
		elseif ip_locationID is null then
			insert into location values (ip_locationID);
            insert into airplane values
            (ip_airlineID, ip_tail_num, ip_seat_capacity, ip_speed, ip_locationID, ip_plane_type, ip_skids, ip_propellers, ip_jet_engines);
		end if;
	end if;
end //
delimiter ;

-- [2] add_airport()
-- -----------------------------------------------------------------------------
/* This stored procedure creates a new airport.  A new airport must have a unique
identifier along with a new and database-wide unique location if it will be used
to support airplane takeoffs and landings.  An airport may have a longer, more
descriptive name.  An airport must also have a city, state, and country designation. */
-- -----------------------------------------------------------------------------
drop procedure if exists add_airport;
delimiter //
create procedure add_airport (in ip_airportID char(3), in ip_airport_name varchar(200),
    in ip_city varchar(100), in ip_state varchar(100), in ip_country char(3), in ip_locationID varchar(50))
sp_main: begin
	if ip_airportID not in (select airportID from airport)
    and ip_state is not null
    and ip_city is not null
    and ip_country is not null
    then
		if ip_locationID is not null and ip_locationID not in (select locationID from location) then
			insert into location values (ip_locationID);
            insert into airport values
            (ip_airportID, ip_airport_name, ip_city, ip_state, ip_country, ip_locationID);
		elseif ip_locationID is null then
			insert into airport values
            (ip_airportID, ip_airport_name, ip_city, ip_state, ip_country, ip_locationID);
		end if;
	end if;
end //
delimiter ;

-- [3] add_person()
-- -----------------------------------------------------------------------------
/* This stored procedure creates a new person.  A new person must reference a unique
identifier along with a database-wide unique location used to determine where the
person is currently located: either at an airport, or on an airplane, at any given
time.  A person must have a first name, and might also have a last name.

A person can hold a pilot role or a passenger role (exclusively).  As a pilot,
a person must have a tax identifier to receive pay, and an experience level.  As a
passenger, a person will have some amount of frequent flyer miles, along with a
certain amount of funds needed to purchase tickets for flights. */
-- -----------------------------------------------------------------------------
drop procedure if exists add_person;
delimiter //
create procedure add_person (in ip_personID varchar(50), in ip_first_name varchar(100),
    in ip_last_name varchar(100), in ip_locationID varchar(50), in ip_taxID varchar(50),
    in ip_experience integer, in ip_miles integer, in ip_funds integer)
sp_main: begin
	if ip_personID not in (select personID from person)
    and ip_locationID is not null and ip_locationID in (select locationID from location) then
		insert into person values
        (ip_personID, ip_first_name, ip_last_name, ip_locationID);
		if ip_miles is not null or ip_funds is not null then
			insert into passengers values (ip_personID, ip_miles, ip_funds);
		end if;
        if ip_taxID is not null then
			insert into pilot values (ip_personID, ip_taxID, ip_experience, NULL);
		end if;
	end if;
end //
delimiter ;

-- [4] grant_or_revoke_pilot_license()
-- -----------------------------------------------------------------------------
/* This stored procedure inverts the status of a pilot license.  If the license
doesn't exist, it must be created; and, if it laready exists, then it must be removed. */
-- -----------------------------------------------------------------------------
drop procedure if exists grant_or_revoke_pilot_license;
delimiter //
create procedure grant_or_revoke_pilot_license (in ip_personID varchar(50), in ip_license varchar(100))
sp_main: begin
	if ip_personID in (select personID from pilot) and ip_license not in (select license from pilot_licenses where personID = ip_personID)
    then
		insert into pilot_licenses values
        (ip_personID, ip_license);
	elseif ip_personID in (select personID from pilot) and ip_license in (select license from pilot_licenses where personID = ip_personID)
	then
		delete from pilot_licenses where personID = ip_personID;
	end if;
end //
delimiter ;

-- [5] offer_flight()
-- -----------------------------------------------------------------------------
/* This stored procedure creates a new flight.  The flight can be defined before
an airplane has been assigned for support, but it must have a valid route.  And
the airplane, if designated, must not be in use by another flight.  The flight
can be started at any valid location along the route except for the final stop,
and it will begin on the ground.  You must also include when the flight will
takeoff along with its cost. */
-- -----------------------------------------------------------------------------
drop procedure if exists offer_flight;
delimiter //
create procedure offer_flight (in ip_flightID varchar(50), in ip_routeID varchar(50),
    in ip_support_airline varchar(50), in ip_support_tail varchar(50), in ip_progress integer,
    in ip_next_time time, in ip_cost integer)
sp_main: begin
	if ip_support_tail is null and ip_routeID in (select routeID from route) then
		insert into flight values
        (ip_flightID, ip_routeID, ip_support_airline, ip_support_tail, ip_progress, ip_next_time, ip_cost);
	elseif ip_routeID in (select routeID from route)
		and ip_progress is not null
        and ip_next_time is not null
        and ip_cost is not null then
			insert into flight values
            (ip_flightID, ip_routeID, ip_support_airline, ip_support_tail, ip_progress, 'on_ground', ip_next_time, ip_cost);
	end if;
end //
delimiter ;

-- [6] flight_landing()
-- -----------------------------------------------------------------------------
/* This stored procedure updates the state for a flight landing at the next airport
along it's route.  The time for the flight should be moved one hour into the future
to allow for the flight to be checked, refueled, restocked, etc. for the next leg
of travel.  Also, the pilots of the flight should receive increased experience, and
the passengers should have their frequent flyer miles updated. */
-- -----------------------------------------------------------------------------
drop procedure if exists flight_landing;
delimiter //
create procedure flight_landing (in ip_flightID varchar(50))
sp_main: begin
	if ip_flightID not in (select flightID from flight) or ip_flightID in (select flightID from flight where airplane_status = 'on_ground') then
		leave sp_main;
	end if;
    update pilot
    join person on pilot.personID = person.personID join airplane on person.locationID = airplane.locationID
    set experience = experience + 1
    where airplane.tail_num in (select support_tail from flight where flightID = ip_flightID) and
    pilot.commanding_flight = ip_flightID;
    update passenger
    set miles = miles + (select sum(leg.distance) from leg join route_path on route_path.legID = leg.legID
    join flight on route_path.routeID = flight.routeID
    where flight.flightID = ip_flightID and route_path.sequence <= flight.progress)
    where personID in (select person.personID from person join airplane on person.locationID = airplane.locationID
    where airplane.tail_num in (select support_tail from flight where flightID = ip_flightID));
    update flight
    set next_time = addtime(next_time, '01:00:00'),
		airplane_status = 'on_ground'
	where flightID = ip_flightID;
end //
delimiter ;

-- [7] flight_takeoff()
-- -----------------------------------------------------------------------------
/* This stored procedure updates the state for a flight taking off from its current
airport towards the next airport along it's route.  The time for the next leg of
the flight must be calculated based on the distance and the speed of the airplane.
And we must also ensure that propeller driven planes have at least one pilot
assigned, while jets must have a minimum of two pilots. If the flight cannot take
off because of a pilot shortage, then the flight must be delayed for 30 minutes. */
-- -----------------------------------------------------------------------------
drop procedure if exists flight_takeoff;
delimiter //
create procedure flight_takeoff (in ip_flightID varchar(50))
sp_main: begin
	declare speed_amt int;
    declare type_plane varchar(100);
    declare distance_amt int;
    declare number_of_pilots int;
    if ip_flightID not in (select flightID from flight) then
		leave sp_main;
	end if;
    if (select airplane_status from flight where flightID = ip_flightID) = 'in_flight' then
		leave sp_main;
	end if;
    if (select progress from flight where flightID = ip_flightID) =
    (select max(sequence) from flight join route_path on flight.routeID = route_path.routeID
    join leg on leg.legID = route_path.legID where flight.flightID = ip_flightID) then
		leave sp_main;
	end if;
	if (select progress from flight where flightID = ip_flightID) is null then
		leave sp_main;
	end if;
    select distance into distance_amt from flight join route_path on flight.routeID = route_path.routeID
    join leg on leg.legID = route_path.legID where flight.flightID = ip_flightID and sequence = progress + 1;
    select airplane.speed, airplane.plane_type into speed_amt, type_plane from flight join airplane
    on flight.support_tail = airplane.tail_num where flight.flightID = ip_flightID;
    select count(*) into number_of_pilots from pilot join airplane on pilot.commanding_flight = flight.flightID
    where flight.flightID = ip_flightID;
    if type_plane = 'jet' and number_of_pilots < 2 then
		update flight set next_time = addtime(next_time, '00:30:00')
        where flight.flightID = ip_flightID;
        leave sp_main;
	end if;
    if type_plane = 'prop' and number_of_pilots < 1 then
		update flight set next_time = addtime(next_time, '00:30:00')
        where flight.flightID = ip_flightID;
        leave sp_main;
	end if;
    update flight
    set airplane_status = 'in_flight', next_time = next_time + interval (distance_amt/speed_amt) hour, progress = progress + 1
    where flight.flightID = ip_flightID;
end //
delimiter ;

-- [8] passengers_board()
-- -----------------------------------------------------------------------------
/* This stored procedure updates the state for passengers getting on a flight at
its current airport.  The passengers must be at the same airport as the flight,
and the flight must be heading towards that passenger's desired destination.
Also, each passenger must have enough funds to cover the flight.  Finally, there
must be enough seats to accommodate all boarding passengers. */
-- -----------------------------------------------------------------------------
drop procedure if exists passengers_board;
delimiter //
create procedure passengers_board (in ip_flightID varchar(50))
sp_main: begin
	drop table if exists flight_info;
    drop table if exists passenger_track;
    create table flight_info as select flightID, locationID from flight join airplane on support_airline = airlineID and support_tail = tail_num;
    create table passenger_track as select flightID, person.locationID as locationID, passenger.personID as personID, airport.airportID as airportID, passenger_vacations.airportID as destination, passenger.funds as funds, flight.cost as cost, leg.departure as departure, leg.arrival as arrival
    from person natural join passenger natural join airport join flight natural join route_path natural join leg
    join passenger_vacations on passenger_vacations.personID = passenger.personID
    where flightID = ip_flightID and funds >= cost;
    delete from passenger_track where flightID != ip_flightID;
    if not (select progress from flight where flightID = ip_flightID) = (select max(sequence) from flight natural join route_path where flightID = ip_flightID)
    then
		if (select count(*) from passenger_track) <= (select seat_capacity from flight join airplane on support_airline = airlineID and
        support_tail = tail_num where flightID = ip_flightID) and
        (select airplane_status from flight join airplane on support_airline = airlineID and
        support_tail = tail_num where flightID = ip_flightID) = 'on_ground'
        then
			update person set locationID = (select locationID from passenger_track where flightID = ip_flightID) where person.personID in (select personID from flight_info);
		end if;
	end if;
end //
delimiter ;

-- [9] passengers_disembark()
-- -----------------------------------------------------------------------------
/* This stored procedure updates the state for passengers getting off of a flight
at its current airport.  The passengers must be on that flight, and the flight must
be located at the destination airport as referenced by the ticket. */
-- -----------------------------------------------------------------------------
drop procedure if exists passengers_disembark;
delimiter //
create procedure passengers_disembark (in ip_flightID varchar(50))
sp_main: begin
	drop table if exists id_info;
    drop table if exists pass_info;
    create table id_info as select flightID, airplane.locationID as locationID, legID, airlineID, tail_num, person.personID as personID,
    airportID, airplane_status from flight join airplane on airlineID = support_airline and tail_num = support_tail
    natural join route_path natural join leg natural join person join passenger_vacations on person.personID = passenger_vacations.personID and flight.progress = passenger_vacations.sequence
    and arrival = passenger_vacations.airportID where flight.progress = route_path.sequence;
    if ip_flightID in (select flightID from id_info where airplane_status = 'on_ground') then
		create table pass_info as select * from (select passenger.personID as pass_personID, flightID, arrival,
        person.locationID as pass_locID, airport.locationID as air_location
        from passenger natural join person natural join airplane join flight on airlineID = support_airline and tail_num = support_tail
        natural join route_path natural join leg join airport on leg.arrival = airport.airportID
        where progress = sequence and flightID = ip_flightID) as pass_info join passenger_vacations on pass_personID = passenger_vacations.personID
        and pass_info.arrival = passenger_vacations.airportID;
        update person set locationID = (select air_location from pass_info where person.personID = pass_personID)
        where personID in (select pass_personID from pass_info);
	end if;
end //
delimiter ;

-- [10] assign_pilot()
-- -----------------------------------------------------------------------------
/* This stored procedure assigns a pilot as part of the flight crew for a given
flight.  The pilot being assigned must have a license for that type of airplane,
and must be at the same location as the flight.  Also, a pilot can only support
one flight (i.e. one airplane) at a time.  The pilot must be assigned to the flight
and have their location updated for the appropriate airplane. */
-- -----------------------------------------------------------------------------
drop procedure if exists assign_pilot;
delimiter //
create procedure assign_pilot (in ip_flightID varchar(50), ip_personID varchar(50))
sp_main: begin
    if ip_personID in (select personID from pilot where commanding_flight is not null) or ((select plane_type from airplane where (airlineID, tail_num) = (select support_airline, support_tail from flight where ip_flightID = flightID)) not in (select license from pilot_licenses where personID = ip_personID)) then 
		leave sp_main; 
	end if; 
    update pilot 
    set commanding_flight = ip_flightID 
    where personID = ip_personID; 
    update person 
    set locationID = (select locationID from airplane where (airlineID, tail_num) = (select support_airline, support_tail from flight where ip_flightID = flightID)) where personID = ip_personID;
end //
delimiter ;

-- [11] recycle_crew()
-- -----------------------------------------------------------------------------
/* This stored procedure releases the assignments for a given flight crew.  The
flight must have ended, and all passengers must have disembarked. */
-- -----------------------------------------------------------------------------
drop procedure if exists recycle_crew;
delimiter //
create procedure recycle_crew (in ip_flightID varchar(50))
sp_main: begin
	declare air_tail varchar(50);
    declare air_loc varchar(50);
    declare passenger_count int;
    declare flight_status varchar(100);
    declare flight_progress int;
    declare leg_sequence int;
    select progress, airplane_status, support_tail into flight_progress, flight_status, air_tail from flight
    where flightID = ip_flightID;
    if flight_progress is null or flight_status is null or air_tail is null then
		leave sp_main;
	end if;
    if flight_status = 'in_air' then
		leave sp_main;
	end if;
    select max(sequence) into leg_sequence from route_path 
    where routeID = (select routeID from flight where flightID = ip_flightID);
    if flight_progress != leg_sequence
    then
		leave sp_main;
	end if;
    select locationID into air_loc from airplane where tail_num = air_tail;
    select count(*) into passenger_count from person where locationID = air_loc and personID in (select personID from passenger);
    if passenger_count > 0 then
		leave sp_main;
	end if;
    
    update pilot join person on pilot.personID = person.personID
    set person.locationID = (select locationID from airport where airportID =
    (select arrival from leg where legID = (select legID from route_path where routeID =
    (select routeID from flight where flightID = ip_flightID)
    order by sequence desc limit 1))), pilot.commanding_flight = NULL
    where pilot.commanding_flight = ip_flightID;
end //
delimiter ;

-- [12] retire_flight()
-- -----------------------------------------------------------------------------
/* This stored procedure removes a flight that has ended from the system.  The
flight must be on the ground, and either be at the start its route, or at the
end of its route.  And the flight must be empty - no pilots or passengers. */
-- -----------------------------------------------------------------------------
drop procedure if exists retire_flight;
delimiter //
create procedure retire_flight (in ip_flightID varchar(50))
sp_main: begin
	drop table if exists plane_track;
    create table plane_track as select * from flight where flightID = ip_flightID and airplane_status = 'on_ground'
    and (progress = (select max(sequence) from flight natural join route_path group by routeID) or progress = 0)
    and (select count(*) from flight
    join airplane on support_tail = tail_num and support_airline = airlineID natural join person where flightID = ip_flightID
    group by locationID) = 0 and (select count(*) from pilot join flight on commanding_flight = flightID
    where flightID = ip_flightID group by flightID) = 0;
    if (select count(*) from plane_track) = 0 then
		delete from flight where flightID = ip_flightID;
	end if;
end //
delimiter ;

-- [13] simulation_cycle()
-- -----------------------------------------------------------------------------
/* This stored procedure executes the next step in the simulation cycle.  The flight
with the smallest next time in chronological order must be identified and selected.
If multiple flights have the same time, then flights that are landing should be
preferred over flights that are taking off.  Similarly, flights with the lowest
identifier in alphabetical order should also be preferred.

If an airplane is in flight and waiting to land, then the flight should be allowed
to land, passengers allowed to disembark, and the time advanced by one hour until
the next takeoff to allow for preparations.

If an airplane is on the ground and waiting to takeoff, then the passengers should
be allowed to board, and the time should be advanced to represent when the airplane
will land at its next location based on the leg distance and airplane speed.

If an airplane is on the ground and has reached the end of its route, then the
flight crew should be recycled to allow rest, and the flight itself should be
retired from the system. */
-- -----------------------------------------------------------------------------
drop procedure if exists simulation_cycle;
delimiter //
create procedure simulation_cycle ()
sp_main: begin
	declare targetID varchar(50);
    drop view if exists lowest_length;
    create view lowest_length as select * from flight where next_time = (select min(next_time) from flight);
    if (select count(*) from lowest_length) > 1 then
		create view flight_landing as select * from lowest_length where airplane_status = 'in_flight' order by flightID limit 1;
        if (select count(*) from flight_landing) = 0 then
			create view take_off as select * from lowest_length where airplane_status = 'on_ground' order by flightID limit 1;
            select flightID into targetID from take_off;
		else
			select flightID into targetID from flight_landing;
		end if;
	else 
		select flightID into targetID from lowest_length;
	end if;
    if (select airplane_status from flight where flightID = targetID) = 'in_flight' then
		call flight_landing(targetID);
        call passengers_disembark(targetID);
	elseif (select airplane_status from flight where flightID = targetID) = 'on_ground' then
		if (select progress from flight where flightID = targetID) = longest_length(targetID) then
			call recycle_crew(targetID);
            call retire_flight(targetID);
		else
			call passengers_board(targetID);
            call flight_takeoff(targetID);
		end if;
	end if;
end //
delimiter ;

-- [14] flights_in_the_air()
-- -----------------------------------------------------------------------------
/* This view describes where flights that are currently airborne are located. */
-- -----------------------------------------------------------------------------
create or replace view flights_in_the_air (departing_from, arriving_at, num_flights,
	flight_list, earliest_arrival, latest_arrival, airplane_list) as
select l.departure as departing_from, l.arrival as arriving_at, count(f.flightID) as num_flights,
group_concat(f.flightID) as flight_list, min(f.next_time) as earliest_arrival, max(f.next_time) as latest_arrival,
group_concat(a.locationID) as airplane_list from flight as f
join route_path as rou on f.routeID = rou.routeID
join leg as l on rou.legID = l.legID
join airplane as a on f.support_airline = a.airlineID and f.support_tail = a.tail_num
where f.progress = rou.sequence and airplane_status = 'in_flight'
group by departing_from, arriving_at;

-- [15] flights_on_the_ground()
-- -----------------------------------------------------------------------------
/* This view describes where flights that are currently on the ground are located. */
-- -----------------------------------------------------------------------------
create or replace view flights_on_the_ground (departing_from, num_flights,
	flight_list, earliest_arrival, latest_arrival, airplane_list) as 
select departing_from, num_flights,flights_list, earliest_arrival, latest_arrival, airplane_list
from (select l.arrival as departing_from, 
        count(*) as num_flights,
        group_concat(f.flightID order by f.flightID asc separator ', ') as flights_list, 
        min(f.next_time) as earliest_arrival, 
        max(f.next_time) as latest_arrival, 
        group_concat(a.locationID order by a.locationID asc separator ', ') as airplane_list
    from flight f
    join route_path rp on f.routeID = rp.routeID and f.progress = rp.sequence
    join leg l on rp.legID = l.legID
    join airplane a on f.support_tail = a.tail_num
    where f.airplane_status = 'on_ground' and f.progress != 0 group by l.arrival
    union all
    select 
        l.departure as departing_from, 
        count(*) as num_flights,
        group_concat(f.flightID order by f.flightID asc separator ', ') as flights_list, 
        min(f.next_time) as earliest_arrival, 
        max(f.next_time) as latest_arrival, 
        group_concat(a.locationID order by a.locationID asc separator ', ') as airplane_list from flight f
    join route_path rp on f.routeID = rp.routeID
    join leg l on rp.legID = l.legID
    join airplane a on f.support_tail = a.tail_num
    where f.airplane_status = 'on_ground' and f.progress = 0 and rp.sequence = (
            select min(sequence)from route_path 
            where routeID = f.routeID)group by l.departure) as combined_results;

-- [16] people_in_the_air()
-- -----------------------------------------------------------------------------
/* This view describes where people who are currently airborne are located. */
-- -----------------------------------------------------------------------------
create or replace view people_in_the_air (departing_from, arriving_at, num_airplanes,
	airplane_list, flight_list, earliest_arrival, latest_arrival, num_pilots,
	num_passengers, joint_pilots_passengers, person_list) as
select l.departure as departing_from, l.arrival as arriving_at, count(distinct l.arrival, l.departure) as num_airplanes,
a.locationID as airplane_list, flightID as flight_list, min(next_time) as earliest_arrival, max(next_time) as latest_arrival,
count(taxID) as num_pilots, count(pe.locationID) - count(taxID) as num_passengers, count(pe.locationID) as joint_pilots_passengers,
(select group_concat(person.personID separator ', ') from person where a.locationID = person.locationID) as person_list
from flight as f join airplane as a on f.support_tail = a.tail_num
inner join route_path as rou on rou.routeID = f.routeID
inner join leg as l on l.legID = rou.legID
inner join person as pe left join pilot as pilo on pe.personID = pilo.personID on a.locationID = pe.locationID
where f.progress = rou.sequence and f.airplane_status = 'in_flight'
group by l.departure, l.arrival, flightID, next_time, next_time, a.locationID
order by l.departure asc;

-- [17] people_on_the_ground()
-- -----------------------------------------------------------------------------
/* This view describes where people who are currently on the ground are located. */
-- -----------------------------------------------------------------------------
create or replace view people_on_the_ground (departing_from, airport, airport_name,
	city, state, country, num_pilots, num_passengers, joint_pilots_passengers, person_list) as
select airp.airportID as departing_from, p.locationID as airport, airp.airport_name, airp.city,airp.state,airp.country,
count(pilot.personID) as num_pilots, count(passenger.personID) as num_passengers, count(p.personID) as joint_pilots_passengers,
group_concat(p.personID) as person_list
from person as p join airport as airp on p.locationID = airp.locationID
left join pilot on p.personID = pilot.personID
left join passenger on p.personID = passenger.personID
group by airp.airportID, p.locationID, airp.airport_name, airp.city, airp.state, airp.country
order by airp.airportID;

-- [18] route_summary()
-- -----------------------------------------------------------------------------
/* This view describes how the routes are being utilized by different flights. */
-- -----------------------------------------------------------------------------
create or replace view route_summary (route, num_legs, leg_sequence, route_length,
	num_flights, flight_list, airport_sequence) as
select ro.routeID as route, count(distinct rou.legID) as num_legs, group_concat(distinct rou.legID order by rou.sequence) as leg_sequence,
route_total.total_distance as route_length, count(distinct f.flightID) as num_flights,
group_concat(distinct f.flightID) as flight_list, group_concat(distinct concat(l.departure, '->', l.arrival) order by rou.sequence) as airport_sequence
from route ro join route_path rou on ro.routeID = rou.routeID
join leg l on rou.legID = l.legID left join flight f on ro.routeID = f.routeID
join (select routeID, sum(distance) as total_distance from route_path rou join leg l on rou.legID = l.legID group by routeID) as route_total
on ro.routeID = route_total.routeID
group by ro.routeID;

-- [19] alternative_airports()
-- -----------------------------------------------------------------------------
/* This view displays airports that share the same city and state. */
-- -----------------------------------------------------------------------------
create or replace view alternative_airports (city, state, country, num_airports,
	airport_code_list, airport_name_list) as
select city, state, country, count(*) as num_airports, group_concat(airportID order by airportID asc separator ', ') as airport_code_list,
group_concat(airport_name order by airportID asc separator ', ') as airport_name_list
from airport group by city, state, country having count(airportID) > 1 order by city, state, country;

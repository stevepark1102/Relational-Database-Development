-- CS4400: Introduction to Database Systems: Monday, September 11, 2023
-- Simple Airline Management System Course Project Database TEMPLATE (v0)

/* This is a standard preamble for most of our scripts.  The intent is to establish
a consistent environment for the database behavior. */
set global transaction isolation level serializable;
set global SQL_MODE = 'ANSI,TRADITIONAL';
set names utf8mb4;
set SQL_SAFE_UPDATES = 0;

set @thisDatabase = 'flight_tracking';
drop database if exists flight_tracking;
create database if not exists flight_tracking;
use flight_tracking;

-- Please enter your team number and names here
#Team 45: Jason Guo, Shi Park, Pranav Peddi, Nirjhar Deb, Andy Zhang

-- Define the database structures
/* You must enter your tables definitions, along with your primary, unique and foreign key
declarations, and data insertion statements here.  You may sequence them in any order that
works for you.  When executed, your statements must create a functional database that contains
all of the data, and supports as many of the constraints as reasonably possible. */

-- Airline
drop table if exists airline;
create table airline(
	airlineID varchar(50),
    revenue int not null,
    PRIMARY KEY(airlineID)
    ) ENGINE = InnoDB;

insert into airline values
('Delta', 53000),
('United', 48000),
('British Airways', 24000),
('Lufthansa', 35000),
('Air_France', 29000),
('KLM', 29000),
('Ryanair', 10000),
('Japan Airlines', 9000),
('China Southern Airlines', 14000),
('Korean Air Lines', 10000),
('American', 52000);

drop table if exists location;
create table location(
	locID varchar(50) not null,
    PRIMARY KEY(locID)
    ) ENGINE = InnoDB;
    
insert into location values
('port_1'),
('port_2'),
('port_3'),
('port_10'),
('port_17'),
('plane_1'),
('plane_5'),
('plane_8'),
('plane_13'),
('plane_20'),
('port_12'),
('port_14'),
('port_15'),
('port_20'),
('port_4'),
('port_16'),
('port_11'),
('port_23'),
('port_7'),
('port_6'),
('port_13'),
('port_21'),
('port_18'),
('port_22'),
('plane_6'),
('plane_18'),
('plane_7');

drop table if exists airplane;    
create table airplane(
	airline_ID varchar(50) not null,
    tail_num varchar(50),
    seat_cap int NOT NULL,
    speed float NOT NULL,
    loc_ID varchar(50),
    plane_type varchar(50), 
    skids bool, 
    props int,
    jets int,
    PRIMARY KEY (airline_ID, tail_num),
    CONSTRAINT forkey1 FOREIGN KEY(airline_ID) REFERENCES airline(airlineID),
    CONSTRAINT forkey2 FOREIGN KEY(loc_ID) REFERENCES location(locID)
) ENGINE = InnoDB;

insert into airplane values
('Delta', 'n106js', 4, 800, 'plane_1', 'jet', null, null, 2.0),
('Delta', 'n110jn', 5, 800, null, 'jet', null, null, 2.0),
('Delta', 'n127js', 4, 600, null, 'jet', null, null, 4.0),
('United', 'n330ss', 4, 800, null, 'jet', null, null, 2.0),
('United', 'n380sd', 5, 400, 'plane_5', 'jet', null, null, 2.0),
('British Airways', 'n616lt', 7, 600, 'plane_6', 'jet', null, null, 2.0),
('British Airways', 'n517ly', 4, 600, 'plane_7', 'jet', null, null, 2.0),
('Lufthansa', 'n620la', 4, 800, 'plane_8', 'jet', null, null, 4.0),
('Lufthansa', 'n401fj', 4, 300, null, null, null, null, null),
('Lufthansa', 'n653fk', 6, 600, null, 'jet', null, null, 2.0),
('Air_France', 'n118fm', 4, 400, null, 'prop', 0.0, 2.0, null),
('Air_France', 'n815pw', 3, 400, null, 'jet', null, null, 2.0),
('KLM', 'n161fk', 4, 600, 'plane_13', 'jet', null, null, 4.0),
('KLM', 'n337as', 5, 400, null, 'jet', null, null, 2.0),
('KLM', 'n256ap', 4, 300, null, 'prop', 0.0, 2.0, null),
('Ryanair', 'n156sq', 8, 600, null, 'jet', null, null, 2.0),
('Ryanair', 'n451fi', 5, 600, null, 'jet', null, null, 4.0),
('Ryanair', 'n341eb', 4, 400, 'plane_18', 'prop', 1.0, 2.0, null),
('Ryanair', 'n353kz', 4, 400, null, 'prop', 1.0, 2.0, null),
('Japan Airlines', 'n305fv', 6, 400, 'plane_20', 'jet', null, null, 2.0),
('Japan Airlines', 'n443wu', 4, 800, null, 'jet', null, null, 4.0),
('China Southern Airlines', 'n454gq', 3, 400, null, null, null, null, null),
('China Southern Airlines', 'n249yk', 4, 400, null, 'prop', 0.0, 2.0, null),
('Korean Air Lines', 'n180co', 5, 600, null, 'jet', null, null, 2.0),
('American', 'n448cs', 4, 400, null, 'prop', 1.0, 2.0, null),
('American', 'n225sb', 8, 800, null, 'jet', null, null, 2.0),
('American', 'n553qn', 5, 800, null, 'jet', null, null, 2.0);

drop table if exists airport;
create table airport(
	airportID char(3) not null,
    airport_name varchar(50) not null,
    city varchar(50) not null,
    state varchar(50) not null,
    country char(3) not null,
    airport_location varchar(50),
    PRIMARY KEY(airportID),
    CONSTRAINT forkey3 FOREIGN KEY(airport_location) REFERENCES location(locID)
) ENGINE = InnoDB;

insert into airport values
('ATL', 'Atlanta Hartsfield_Jackson International', 'Atlanta', 'Georgia', 'USA', 'port_1'),
('DXB', 'Dubai International', 'Dubai', 'Al Garhoud', 'UAE', 'port_2'),
('HND', 'Tokyo International Haneda', 'Ota City', 'Tokyo', 'JPN', 'port_3'),
('LHR', 'London Heathrow', 'London', 'England', 'GBR', 'port_4'),
('IST', 'Istanbul International', 'Arnavutkoy', 'Istanbul ', 'TUR', null),
('DFW', 'Dallas_Fort Worth International', 'Dallas', 'Texas', 'USA', 'port_6'),
('CAN', 'Guangzhou International', 'Guangzhou', 'Guangdong', 'CHN', 'port_7'),
('DEN', 'Denver International', 'Denver', 'Colorado', 'USA', null),
('LAX', 'Los Angeles International', 'Los Angeles', 'California', 'USA', null),
('ORD', 'O_Hare International', 'Chicago', 'Illinois', 'USA', 'port_10'),
('AMS', 'Amsterdam Schipol International', 'Amsterdam', 'Haarlemmermeer', 'NLD', 'port_11'),
('CDG', 'Paris Charles de Gaulle', 'Roissy_en_France', 'Paris', 'FRA', 'port_12'),
('FRA', 'Frankfurt International', 'Frankfurt', 'Frankfurt_Rhine_Main', 'DEU', 'port_13'),
('MAD', 'Madrid Adolfo Suarez_Barajas', 'Madrid', 'Barajas', 'ESP', 'port_14'),
('BCN', 'Barcelona International', 'Barcelona', 'Catalonia', 'ESP', 'port_15'),
('FCO', 'Rome Fiumicino', 'Fiumicino', 'Lazio', 'ITA', 'port_16'),
('LGW', 'London Gatwick', 'London', 'England', 'GBR', 'port_17'),
('MUC', 'Munich International', 'Munich', 'Bavaria', 'DEU', 'port_18'),
('MDW', 'Chicago Midway International', 'Chicago', 'Illinois', 'USA', null),
('IAH', 'George Bush Intercontinental', 'Houston', 'Texas', 'USA', 'port_20'),
('HOU', 'William P_Hobby International', 'Houston', 'Texas', 'USA', 'port_21'), 
('NRT', 'Narita International', 'Narita', 'Chiba', 'JPN', 'port_22'),
('BER', 'Berlin Brandenburg Willy Brandt International', 'Berlin', 'Schonefeld', 'DEU', 'port_23');

drop table if exists route;
create table route(
	routeID varchar(50) not null,
    PRIMARY KEY(routeID)
) ENGINE = InnoDB;

insert into route values
('americas_hub_exchange'),
('americas_one'),
('americas_three'),
('americas_two'),
('big_europe_loop'),
('euro_north'),
('euro_south'),
('germany_local'),
('pacific_rim_tour'),
('south_euro_loop'),
('texas_local');

drop table if exists leg;
create table leg(
	legID varchar(10),
    depart char(3) not null,
    arrive char(3) not null,
    distance int not null,
    PRIMARY KEY(legID),
    CONSTRAINT forkey4 FOREIGN KEY (depart) REFERENCES airport(airportID),
    CONSTRAINT forkey5 FOREIGN KEY (arrive) REFERENCES airport(airportID)
) ENGINE = InnoDB;

insert into leg values
('leg_4','ATL','ORD',600),
('leg_2','ATL','AMS',3900),
('leg_1','AMS','BER',400),
('leg_31','ORD','CDG',3700),
('leg_14','CDG','MUC',400),
('leg_3','ATL','LHR',3700),
('leg_22','LHR','BER',600),
('leg_23','LHR','MUC',500),
('leg_29','MUC','FCO',400),
('leg_16','FCO','MAD',800),
('leg_25','MAD','CDG',600),
('leg_13','CDG','LHR',200),
('leg_24','MAD','BCN',300),
('leg_5','BCN','CDG',500),
('leg_27','MUC','BER',300),
('leg_8','BER','LGW',600),
('leg_21','LGW','BER',600),
('leg_9','BER','MUC',300),
('leg_28','MUC','CDG',400),
('leg_11','CDG','BCN',500),
('leg_6','BCN','MAD',300),
('leg_26','MAD','FCO',800),
('leg_30','MUC','FRA',200),
('leg_17','FRA','BER',300),
('leg_7','BER','CAN',4700),
('leg_10','CAN','HND',1600),
('leg_18','HND','NRT',100),
('leg_12','CDG','FCO',600),
('leg_15','DFW','IAH',200),
('leg_20','IAH','HOU',100),
('leg_19','HOU','DFW',300);

drop table if exists flight;
create table flight(
	flightID varchar(50) not null,
    routeID varchar(50) not null,
    support_airline varchar(50) not null,
    support_tail varchar(50) not null,
    progress int not null,
    airplane_status varchar(50),
    next_time time,
    cost float not null,
    PRIMARY KEY(flightID),
    CONSTRAINT forkey6 FOREIGN KEY (routeID) REFERENCES route(routeID),
    CONSTRAINT forkey7 FOREIGN KEY (support_airline, support_tail) REFERENCES airplane(airline_ID, tail_num)
) ENGINE = InnoDB;

insert into flight values
('dl_10', 'americas_one', 'Delta', 'n106js', 1, 'in_flight', '08:00:00', 200),
('un_38','americas_three','United','n380sd',2,'in_flight','14:30:00',200),
('ba_61','americas_two','British Airways','n616lt',0,'on_ground','09:30:00',200),
('lf_20','euro_north','Lufthansa','n620la',3,'in_flight','11:00:00',300),
('km_16', 'euro_south', 'KLM', 'n161fk', 6, 'in_flight', '14:00:00', 400),
('ba_51','big_europe_loop','British Airways','n517ly',0,'on_ground','11:30:00',100),
('ja_35','pacific_rim_tour','Japan Airlines','n305fv',1,'in_flight','09:30:00',300),
('ry_34','germany_local','Ryanair','n341eb',0,'on_ground','15:00:00',100);

drop table if exists person;
create table person(
	personID varchar(50) not null,
    first_name varchar(50) not null,
    last_name varchar(50),
    locationID varchar(50) not null,
    PRIMARY KEY(personID),
    CONSTRAINT forkey8 FOREIGN KEY (locationID) REFERENCES location(locID)
) ENGINE = InnoDB;

insert into person values
('p1', 'Jeanne', 'Nelson', 'port_1'),
('p10', 'Lawrence', 'Morgan', 'port_3'),
('p11', 'Sandra', 'Cruz', 'port_3'),
('p12', 'Dan', 'Ball', 'port_3'),
('p13', 'Bryant', 'Figueroa', 'port_3'),
('p14', 'Dana', 'Perry', 'port_3'),
('p15', 'Matt', 'Hunt', 'port_10'),
('p16', 'Edna', 'Brown', 'port_10'),
('p17', 'Ruby', 'Burgess', 'port_10'),
('p18', 'Esther', 'Pittman', 'port_10'),
('p19', 'Doug', 'Fowler', 'port_17'),
('p2', 'Roxanne', 'Byrd', 'port_1'),
('p20', 'Thomas', 'Olson', 'port_17'),
('p21', 'Mona', 'Harrison', 'plane_1'),
('p22', 'Arlene', 'Massey', 'plane_1'),
('p23', 'Judith', 'Patrick', 'plane_1'),
('p24', 'Reginald', 'Rhodes', 'plane_5'),
('p25', 'Vincent', 'Garcia', 'plane_5'),
('p26', 'Cheryl', 'Moore', 'plane_5'),
('p27', 'Michael', 'Rivera', 'plane_8'),
('p28', 'Luther', 'Matthews', 'plane_8'),
('p29', 'Moses', 'Parks', 'plane_13'),
('p3', 'Tanya', 'Nguyen', 'port_1'),
('p30', 'Ora', 'Steele', 'plane_13'),
('p31', 'Antonio', 'Flores', 'plane_13'),
('p32', 'Glenn', 'Ross', 'plane_13'),
('p33', 'Irma', 'Thomas', 'plane_20'),
('p34', 'Ann', 'Maldonado', 'plane_20'),
('p35', 'Jeffrey', 'Cruz', 'port_12'),
('p36', 'Sonya', 'Price', 'port_12'),
('p37', 'Tracy', 'Hale', 'port_12'),
('p38', 'Albert', 'Simmons', 'port_14'),
('p39', 'Karen', 'Terry', 'port_15'),
('p4', 'Kendra', 'Jacobs', 'port_1'),
('p40', 'Glen', 'Kelley', 'port_20'),
('p41', 'Brooke', 'Little', 'port_3'),
('p42','Daryl','Nguyen','port_4'),
('p43','Judy','Willis','port_14'),
('p44','Marco','Klein','port_15'),
('p45','Angelica','Hampton','port_16'),
('p5','Jeff','Burton','port_1'),
('p6','Randal','Parks','port_1'),
('p7','Sonya','Owens','port_2'),
('p8','Bennie','Palmer','port_2'),
('p9','Marlene','Warner','port_3');

drop table if exists pilot;
create table pilot(
	personID varchar(10),
    taxID varchar(11) not null,
    experience int not null,
    flying_airline varchar(50),
    flying_tail varchar(50),
    associated_flight varchar(50),
    PRIMARY KEY (personID),
    UNIQUE KEY(taxID),
    CONSTRAINT forkey9 FOREIGN KEY (personID) REFERENCES person(personID),
    CONSTRAINT forkey10 FOREIGN KEY (flying_airline, flying_tail) REFERENCES airplane(airline_ID, tail_num)
) ENGINE = InnoDB;

insert into pilot values
('p1', '330-12-6907', 31.0, 'Delta', 'n106js', 'dl_10'),
('p2', '842-88-1257', 9.0, 'Delta', 'n106js', 'dl_10'),
('p3', '750-24-7616', 11.0, 'United', 'n380sd', 'un_38'),
('p4', '776-21-8098', 24.0, 'United', 'n380sd', 'un_38'),
('p5', '933-93-2165',27.0,'British Airways','n616lt','ba_61'),
('p6','707-84-4555',38.0,'British Airways','n616lt','ba_61'),
('p7','450-25-5617',13.0,'Lufthansa','n620la','lf_20'),
('p8','701-38-2179',12.0,'Ryanair','n341eb','ry_34'),
('p9','936-44-6941',13.0,'Lufthansa','n620la','lf_20'),
('p10','769-60-1266', 15.0, 'Lufthansa', 'n620la', 'lf_20'),
('p11', '369-22-9505', 22.0, 'KLM', 'n161fk', 'km_16'),
('p12', '680-92-5329', 24.0, 'Ryanair', 'n341eb', 'ry_34'),
('p13', '513-40-4168', 24.0, 'KLM', 'n161fk', 'km_16'),
('p14','454-71-7847', 13.0, 'KLM', 'n161fk', 'km_16'),
('p15','153-47-8101', 30.0, 'Japan Airlines', 'n305fv', 'ja_35'),
('p16', '598-47-5172', 28.0, 'Japan Airlines', 'n305fv', 'ja_35'),
('p17', '865-71-6800', 36.0, null, null, null),
('p18', '250-86-2784', 23.0, null, null, null),
('p19', '386-39-7881', 2.0, null, null, null),
('p20', '522-44-3098', 28.0, null, null, null);

drop table if exists license;
create table license(
	pilotID varchar(50) not null,
    license_type varchar(50) not null,
    PRIMARY KEY (pilotID, license_type),
    CONSTRAINT forkey11 FOREIGN KEY (pilotID) REFERENCES pilot(personID)
) ENGINE = InnoDB;

insert into license values
('p1', 'jets'),
('p2', 'jets, props'),
('p3', 'jets'),
('p4', 'jets, props'),
('p5','jets'),
('p6','jets, props'),
('p7','jets'),
('p8','props'),
('p9','jets, props, testing'),
('p10','jets'),
('p11', 'jets, props'),
('p12', 'props'),
('p13', 'jets'),
('p14', 'jets'),
('p15', 'jets, props, testing'),
('p16', 'jets'),
('p17', 'jets, props'),
('p18', 'jets'),
('p19', 'jets'),
('p20', 'jets');

drop table if exists passenger;
create table passenger(
	personID varchar(50),
    miles int not null,
    funds int,
    PRIMARY KEY (personID),
    CONSTRAINT forkey12 FOREIGN KEY (personID) REFERENCES person(personID)
) ENGINE = InnoDB;

insert into passenger values
('p21', 771.0, 700.0),
('p22', 374.0, 200.0),
('p23', 414.0, 400.0),
('p24', 292.0, 500.0),
('p25', 390.0, 300.0),
('p26', 302.0, 600.0),
('p27', 470.0, 400.0),
('p28', 208.0, 400.0),
('p29', 292.0, 700.0),
('p30', 686.0, 500.0),
('p31', 547.0, 400.0),
('p32', 257.0, 500.0),
('p33', 564.0, 600.0),
('p34', 211.0, 200.0),
('p35', 233.0, 500.0),
('p36', 293.0, 400.0),
('p37', 552.0, 700.0),
('p38', 812.0, 700.0),
('p39', 541.0, 400.0),
('p40', 441.0, 700.0),
('p41', 875.0, 300.0),
('p42', 691.0, 500.0),
('p43', 572.0, 300.0),
('p44', 572.0, 500.0),
('p45', 663.0, 500.0);

drop table if exists contain;
create table contain(
	routeID varchar(50) not null,
    legID varchar(50) not null,
    sequence varchar(50) not null,
    PRIMARY KEY (routeID, legID, sequence),
    CONSTRAINT forkey13 FOREIGN KEY (routeID) REFERENCES route(routeID),
    CONSTRAINT forkey14 FOREIGN KEY (legID) REFERENCES leg(legID)
) ENGINE = InnoDB;

insert into contain values
('americas_hub_exchange', 'leg_4', 1),
('americas_one', 'leg_2', 1),
('americas_one', 'leg_1', 2),
('americas_three', 'leg_31', 1),
('americas_three', 'leg_14', 2),
('americas_two', 'leg_3', 1),
('americas_two', 'leg_22', 2),
('big_europe_loop', 'leg_23', 1),
('big_europe_loop', 'leg_29', 2),
('big_europe_loop', 'leg_16', 3),
('big_europe_loop', 'leg_25', 4),
('big_europe_loop', 'leg_13', 5),
('euro_north', 'leg_16', 1),
('euro_north', 'leg_24', 2),
('euro_north', 'leg_5', 3),
('euro_north', 'leg_14', 4),
('euro_north', 'leg_27', 5),
('euro_north', 'leg_8', 6),
('euro_south', 'leg_21', 1),
('euro_south', 'leg_9', 2),
('euro_south', 'leg_28', 3),
('euro_south', 'leg_11', 4),
('euro_south', 'leg_6', 5),
('euro_south', 'leg_26', 6),
('germany_local', 'leg_9', 1),
('germany_local', 'leg_30', 2),
('germany_local', 'leg_17', 3),
('pacific_rim_tour', 'leg_7', 1),
('pacific_rim_tour', 'leg_10', 2),
('pacific_rim_tour', 'leg_18', 3),
('south_euro_loop', 'leg_16', 1),
('south_euro_loop', 'leg_24', 2),
('south_euro_loop', 'leg_5', 3),
('south_euro_loop', 'leg_12', 4),
('texas_local', 'leg_15', 1),
('texas_local', 'leg_20', 2),
('texas_local', 'leg_19', 3);

drop table if exists vacation;
create table vacation(
	passengerID varchar(5),
    destination varchar(50),
    sequence varchar(50),
    PRIMARY KEY (passengerID, destination, sequence),
    CONSTRAINT forkey15 FOREIGN KEY (passengerID) REFERENCES passenger(personID)
) ENGINE = InnoDB;

insert into vacation values
('p21', 'AMS', 1),
('p22', 'AMS', 1),
('p23', 'BER', 1),
('p24', 'MUC', 1),
('p24', 'CDG', 2),
('p25', 'MUC', 1),
('p26', 'MUC', 1),
('p27', 'BER', 1),
('p28', 'LGW', 1),
('p29', 'FCO', 1),
('p29', 'LHR', 2),
('p30', 'FCO', 1),
('p30', 'MAD', 2),
('p31', 'FCO', 1),
('p32', 'FCO', 1),
('p33', 'CAN', 1),
('p34', 'HND', 1),
('p35', 'LGW', 1),
('p36', 'FCO', 1),
('p37', 'FCO', 1),
('p37', 'LGW', 2),
('p37', 'CDG', 3),
('p38', 'MUC', 1),
('p39', 'MUC', 1),
('p40', 'HND', 1);

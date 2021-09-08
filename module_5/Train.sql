--	Задание 4.1
--	1/1 point (graded)
--	База данных содержит список аэропортов практически всех крупных городов России. 
--	В большинстве городов есть только один аэропорт. Исключение составляет:
----------------------------------------------------------------------------------------------------------------------
select
    count(ai.airport_code),
    ai.city
FROM dst_project.Airports ai
group by ai.city
having count(ai.airport_code) > 1
order by 1 desc
----------------------------------------------------------------------------------------------------------------------
--	Ответ: 3 - Moscow, 2 - Ulyanovsk

----------------------------------------------------------------------------------------------------------------------
--	Задание 4.2
--	4 points possible (graded)
	
--	Вопрос 1. Таблица рейсов содержит всю информацию о прошлых, текущих и запланированных рейсах. 
--	Сколько всего статусов для рейсов определено в таблице?
	----------------------------------------------------------------------------------------------------------------------
	select
		count(distinct fl.status)
	FROM dst_project.Flights fl
	----------------------------------------------------------------------------------------------------------------------
--	Ответ: 6

	----------------------------------------------------------------------------------------------------------------------
--	Вопрос 2. Какое количество самолетов находятся в воздухе на момент среза в базе (статус 
--	рейса «самолёт уже вылетел и находится в воздухе»).
	----------------------------------------------------------------------------------------------------------------------
	select
		count(fl.aircraft_code)
	FROM dst_project.Flights fl
	where fl.status = 'Departed'
	----------------------------------------------------------------------------------------------------------------------
--	Ответ: 58

	----------------------------------------------------------------------------------------------------------------------
--	Вопрос 3. Места определяют схему салона каждой модели. Сколько мест имеет самолет модели  (Boeing 777-300)?
	----------------------------------------------------------------------------------------------------------------------
	select
		count(se.seat_no)
	FROM dst_project.seats se
	    join dst_project.aircrafts airc on se.aircraft_code = airc.aircraft_code
	where airc.model = 'Boeing 777-300'
	----------------------------------------------------------------------------------------------------------------------
--	Ответ: 402

	----------------------------------------------------------------------------------------------------------------------
--	Вопрос 4. Сколько состоявшихся (фактических) рейсов было совершено между 1 апреля 2017 года и 
--	1 сентября 2017 года?
	----------------------------------------------------------------------------------------------------------------------
	select
		count(fl.aircraft_code)
	FROM dst_project.Flights fl
	where (fl.actual_departure > '2017-04-01 00:00:00' and fl.actual_arrival < '2017-09-01 00:00:00')
			and (fl.status = 'Arrived')
	----------------------------------------------------------------------------------------------------------------------			
--	Ответ: 74221

----------------------------------------------------------------------------------------------------------------------
--	Задание 4.3
--	6 points possible (graded)
	
--	Вопрос 1. Сколько всего рейсов было отменено по данным базы?
	----------------------------------------------------------------------------------------------------------------------		
	select
	   count(fl.aircraft_code)
	FROM dst_project.Flights fl
	where fl.status = 'Cancelled' 
	----------------------------------------------------------------------------------------------------------------------		
--	Ответ: 437

	----------------------------------------------------------------------------------------------------------------------
--	Вопрос 2. Сколько самолетов моделей типа Boeing, Sukhoi Superjet, Airbus находится в базе авиаперевозок?
	----------------------------------------------------------------------------------------------------------------------
	select
	   count(cr.model),
	   'Boeing' name_model
	FROM dst_project.AIRCRAFTS cr 
	where POSITION ('Boeing' IN cr.model) > 0 
	union
	select
	   count(cr.model),
	   'Sukhoi Superjet' name_model
	FROM dst_project.AIRCRAFTS cr 
	where POSITION ('Sukhoi Superjet' IN cr.model) > 0 
	union
	select
	   count(cr.model),
	   'Airbus' name_model
	FROM dst_project.AIRCRAFTS cr 
	where POSITION ('Airbus' IN cr.model) > 0 
	----------------------------------------------------------------------------------------------------------------------
--	Ответ: Boeing: 3, Sukhoi Superjet: 1, Airbus: 3

	----------------------------------------------------------------------------------------------------------------------
--	Вопрос 3. В какой части (частях) света находится больше аэропортов?
	----------------------------------------------------------------------------------------------------------------------
	select
		count(ai.airport_code),
		LEFT(ai.timezone, POSITION('/' in ai.timezone)-1) part
		FROM dst_project.Airports ai 
		group by 2
		order by 1 desc,2
	----------------------------------------------------------------------------------------------------------------------
--	Ответ: 52 - Asia, 52 - Europe

	----------------------------------------------------------------------------------------------------------------------
--	Вопрос 4. У какого рейса была самая большая задержка прибытия за все время сбора данных? Введите id рейса (flight_id).
	----------------------------------------------------------------------------------------------------------------------
	select
	   fl.flight_id
	FROM dst_project.FLIGHTS fl 
	where fl.actual_arrival is not null
	order by (fl.actual_arrival - fl.scheduled_arrival) desc
	limit 1
	----------------------------------------------------------------------------------------------------------------------
--	Ответ: 157571

----------------------------------------------------------------------------------------------------------------------
--	Задание 4.4
--	4 points possible (graded)
	
--	Вопрос 1. Когда был запланирован самый первый вылет, сохраненный в базе данных?
	----------------------------------------------------------------------------------------------------------------------
	select
	   fl.scheduled_departure
	FROM dst_project.FLIGHTS fl 
	order by 1
	limit 1
	----------------------------------------------------------------------------------------------------------------------
--	Ответ: август 14, 2016, 11:45 вечера

	----------------------------------------------------------------------------------------------------------------------
--	Вопрос 2. Сколько минут составляет запланированное время полета в самом длительном рейсе?
	----------------------------------------------------------------------------------------------------------------------
	select
	   scheduled_arrival - fl.scheduled_departure delay
	FROM dst_project.FLIGHTS fl 
	order by 1 desc
	limit 1
	----------------------------------------------------------------------------------------------------------------------
--	Ответ: 0 years 0 mons 0 days 8 hours 50 mins 0.00 secs
	
	----------------------------------------------------------------------------------------------------------------------
	select
	   EXTRACT(HOUR from (scheduled_arrival - fl.scheduled_departure)) * 60 + 
	   EXTRACT(minute from (scheduled_arrival - fl.scheduled_departure)) minutes
	FROM dst_project.FLIGHTS fl 
	order by 1 desc
	limit 1
	----------------------------------------------------------------------------------------------------------------------
--	Ответ: 530

	----------------------------------------------------------------------------------------------------------------------
--	Вопрос 3. Между какими аэропортами пролегает самый длительный по времени запланированный рейс?
	----------------------------------------------------------------------------------------------------------------------
	select
	   fl.departure_airport,
	   fl.arrival_airport
	FROM dst_project.FLIGHTS fl 
	order by (scheduled_arrival - fl.scheduled_departure) desc
	limit 1
	----------------------------------------------------------------------------------------------------------------------
--	Ответ: DME UUS

	----------------------------------------------------------------------------------------------------------------------
--	Вопрос 4. Сколько составляет средняя дальность полета среди всех самолетов в минутах? Секунды округляются в меньшую сторону 
--	(отбрасываются до минут).
	----------------------------------------------------------------------------------------------------------------------
	with a as 
	(
	select
	   EXTRACT(HOUR from (scheduled_arrival - fl.scheduled_departure)) * 60 min1,
	   EXTRACT(minute from (scheduled_arrival - fl.scheduled_departure)) min2
	FROM dst_project.FLIGHTS fl 
	) 
	select 
		avg(a.min1 + a.min2)::int
	from a 	
	----------------------------------------------------------------------------------------------------------------------
--	Ответ: 128

----------------------------------------------------------------------------------------------------------------------
--	Задание 4.5
--	3 points possible (graded)

--	Вопрос 1. Мест какого класса у SU9 больше всего?
	----------------------------------------------------------------------------------------------------------------------
	select
		se.fare_conditions
	FROM dst_project.Seats se 
	where se.aircraft_code = 'SU9'
	group by 1
	order by count(se.seat_no) desc
	limit 1
	----------------------------------------------------------------------------------------------------------------------
--	Ответ: Economy

	----------------------------------------------------------------------------------------------------------------------
--	Вопрос 2. Какую самую минимальную стоимость составило бронирование за всю историю?
	----------------------------------------------------------------------------------------------------------------------
	select
		bo.total_amount
	FROM dst_project.BOOKINGS bo 
	order by 1
	limit 1
	----------------------------------------------------------------------------------------------------------------------
--	Ответ: 3400

	----------------------------------------------------------------------------------------------------------------------
--  Вопрос 3. Какой номер места был у пассажира с id = 4313 788533?
	----------------------------------------------------------------------------------------------------------------------
	select
		bo.seat_no
	FROM dst_project.TICKETS ti
		join dst_project.BOARDING_PASSES bo on  ti.ticket_no = bo.ticket_no
	where ti.passenger_id = '4313 788533'
	----------------------------------------------------------------------------------------------------------------------
--	Ответ: 2A

----------------------------------------------------------------------------------------------------------------------
--	Задание 5.1
--	5 points possible (graded)

--	Вопрос 1. Анапа — курортный город на юге России. Сколько рейсов прибыло в Анапу за 2017 год?
	----------------------------------------------------------------------------------------------------------------------
	select
		count(fl.flight_id)
	FROM dst_project.FLIGHTS fl
		join dst_project.AIRPORTS ai on fl.arrival_airport = ai.airport_code
	where ai.city = 'Anapa' and fl.status = 'Arrived' and EXTRACT(YEAR from fl.actual_arrival) = 2017 
	----------------------------------------------------------------------------------------------------------------------
--	Ответ: 486

	**********************************************************************************************************************
--	Вопрос 2. Сколько рейсов из Анапы вылетело зимой 2017 года?
	----------------------------------------------------------------------------------------------------------------------
	select  count(1)
	from dst_project.flights
	where departure_airport = 'AAQ' and (date_trunc('month', actual_departure) in ('2017-01-01', '2017-02-01', '2017-12-01'))
	and status not in ('Cancelled')
	----------------------------------------------------------------------------------------------------------------------	
--	Ответ: 127

	----------------------------------------------------------------------------------------------------------------------
--	Вопрос 3. Посчитайте количество отмененных рейсов из Анапы за все время.
	----------------------------------------------------------------------------------------------------------------------
	select
		count(fl.flight_id)
	FROM dst_project.FLIGHTS fl
		join dst_project.AIRPORTS ai on fl.departure_airport = ai.airport_code
	where ai.city = 'Anapa' and fl.status = 'Cancelled' 
	----------------------------------------------------------------------------------------------------------------------
--	Ответ: 1

	----------------------------------------------------------------------------------------------------------------------
--	Вопрос 4. Сколько рейсов из Анапы не летают в Москву?
	----------------------------------------------------------------------------------------------------------------------
	select
		count(fl.flight_id)
	FROM dst_project.FLIGHTS fl
		join dst_project.AIRPORTS ai on fl.departure_airport = ai.airport_code
			join dst_project.AIRPORTS air on fl.arrival_airport = air.airport_code
	where ai.city = 'Anapa' and air.city != 'Moscow' 
	----------------------------------------------------------------------------------------------------------------------
--	Ответ: 453

	----------------------------------------------------------------------------------------------------------------------
--	Вопрос 5. Какая модель самолета летящего на рейсах из Анапы имеет больше всего мест?
	----------------------------------------------------------------------------------------------------------------------
	select
		aircr.model
	FROM dst_project.FLIGHTS fl
		join dst_project.AIRPORTS ai on fl.departure_airport = ai.airport_code
			join dst_project.AIRCRAFTS aircr on fl.aircraft_code = aircr.aircraft_code
				join dst_project.SEATS se on fl.aircraft_code = se.aircraft_code
	where ai.city = 'Anapa' 
	group by 1
	order by count(se.aircraft_code) desc
	limit 1
	----------------------------------------------------------------------------------------------------------------------
--	Ответ: Boeing 737-300


----------------------------------------------------------------------------------------------------------------------
-- ЗАДАЧА
-- Напомним, что вам предстоит выяснить, от каких самых малоприбыльных рейсов из Анапы мы можем отказаться в зимнее время. 
-- Вы не знаете, по каким критериям ваше руководство будет отбирать рейсы, поэтому решаете собрать как можно больше информации, 
-- содержащейся в вашей базе, в один датасет. 
----------------------------------------------------------------------------------------------------------------------
SELECT 
    fl.flight_id,                  --  id рейса
    fl.flight_no,                  -- номер рейса
    airp1.city dep_city,    	   -- город вылета Анапа
    airp1.timezone dep_tz,         -- часовой пояс аэропорта вылета
    airp1.longitude dep_lon,       -- долгота аэропорта вылета
    airp1.latitude dep_lat,        -- широта аэропорта вылета
    airp2.city arr_city,       	   -- город прибытия
    airp2.timezone arr_tz,         -- часовой пояс аэропорта прибытия
    airp2.longitude arr_lon,       -- долгота аэропорта прибытия
    airp2.latitude arr_lat,        -- широта аэропорта прибытия
    airc.model,                    -- модель самолета
    airc.range,                    -- максимальная дальность полёта в километрах 
    fl.scheduled_departure,        -- запланированные дата и время вылета
    fl.scheduled_arrival,          -- запланированные дата и время прибытия
    fl.actual_departure,           -- реальные время вылет
    fl.actual_arrival,             -- реальные время прибытия
    fl.departure_airport,          -- аэропорт вылета
    fl.arrival_airport,            -- аэропорт прибытия
    fl.aircraft_code,              -- трёхзначный код самолета
    EXTRACT(HOUR from (fl.scheduled_arrival - fl.scheduled_departure)) * 60 + EXTRACT(minute from (fl.scheduled_arrival - fl.scheduled_departure)) way_minutes,  -- время полета
    se.count_seats,                -- количество мест в самолете
    ti_fl.count_ticket,            -- количество билетов, проданных по рейсу
    (ti_fl.count_ticket * 100)/se.count_seats::int occupancy,     -- процент заполненности самолета на рейсе
    ti_fl.sum_amout,               -- стоимость проданных билетов
    boo.sum_booking,               -- стоимость брони
    tf1.count_Economy,             -- количество проданных билетов Эконом класса
    tf1.sum_Econom,                -- стоимость проданных билетов Эконом класса
    tf2.count_Business,            -- количество проданных билетов Бизнес класса
    tf2.sum_Business               -- стоимость проданных билетов Бизнес класса
FROM dst_project.flights fl
    join dst_project.airports airp1 on fl.departure_airport = airp1.airport_code
        join dst_project.airports airp2 on fl.arrival_airport = airp2.airport_code
            join dst_project.aircrafts airc on fl.aircraft_code = airc.aircraft_code
                join (SELECT 
                        fl.flight_id,                  --  id рейса
                        count(se.seat_no) count_seats  -- количество мест в самолете всего
                        FROM dst_project.flights fl
                                join dst_project.seats se on fl.aircraft_code = se.aircraft_code
                        WHERE fl.departure_airport = 'AAQ'
                          AND (date_trunc('month', fl.scheduled_departure) in ('2017-01-01','2017-02-01', '2017-12-01'))
                          AND fl.status not in ('Cancelled')
                        group by 1) se on fl.flight_id = se.flight_id
                    left join (SELECT
                                    fl.flight_id,                                  --  id рейса
                                    count(distinct tf0.ticket_no) count_ticket,    -- количество билетов, проданных по рейсу
                                    sum(tf0.amount) sum_amout                      -- стоимость проданных билетов
                                    FROM dst_project.flights fl
                                        left join dst_project.ticket_flights tf0 on fl.flight_id = tf0.flight_id
                                    WHERE fl.departure_airport = 'AAQ'
                                      AND (date_trunc('month', fl.scheduled_departure) in ('2017-01-01','2017-02-01', '2017-12-01'))
                                      AND fl.status not in ('Cancelled')
                                    group by 1) ti_fl on fl.flight_id = ti_fl.flight_id        
                        left join (SELECT 
                                fl.flight_id,                                   --  id рейса
                                sum(boo.total_amount) sum_booking               -- стоимость брони
                                FROM dst_project.flights fl
                                        left join dst_project.ticket_flights ti_fl on fl.flight_id = ti_fl.flight_id
                                            left join dst_project.tickets ti on ti_fl.ticket_no = ti.ticket_no
                                                left join dst_project.bookings boo on ti.book_ref = boo.book_ref
                                WHERE fl.departure_airport = 'AAQ'
                                  AND (date_trunc('month', fl.scheduled_departure) in ('2017-01-01','2017-02-01', '2017-12-01'))
                                  AND fl.status not in ('Cancelled')
                                group by 1) boo on fl.flight_id = boo.flight_id
                            left join (SELECT                                         -- данные по Эконом классу
                                     fl.flight_id, 
                                    count(distinct tf1.ticket_no) count_Economy,
                                    sum( tf1.amount) sum_Econom
                                    FROM dst_project.flights fl
                                       left join dst_project.ticket_flights tf1 on fl.flight_id = tf1.flight_id
                                    WHERE fl.departure_airport = 'AAQ' 
                                        AND tf1.fare_conditions = 'Economy'   
                                      AND (date_trunc('month', fl.scheduled_departure) in ('2017-01-01','2017-02-01', '2017-12-01'))
                                      AND fl.status not in ('Cancelled')
                                    group by 1) tf1 on fl.flight_id = tf1.flight_id
                                left join (SELECT                                      -- данные по Бизнес классу
                                        fl.flight_id, 
                                        count(distinct tf2.ticket_no) count_Business,
                                        sum(tf2.amount) sum_Business
                                        FROM dst_project.flights fl
                                           left join dst_project.ticket_flights tf2 on fl.flight_id = tf2.flight_id
                                        WHERE fl.departure_airport = 'AAQ' 
                                            AND tf2.fare_conditions = 'Business'   
                                          AND (date_trunc('month', fl.scheduled_departure) in ('2017-01-01','2017-02-01', '2017-12-01'))
                                          AND fl.status not in ('Cancelled')
                                        group by 1) tf2 on fl.flight_id = tf2.flight_id
WHERE fl.departure_airport = 'AAQ'
  AND (date_trunc('month', fl.scheduled_departure) in ('2017-01-01','2017-02-01', '2017-12-01'))
  AND fl.status not in ('Cancelled')

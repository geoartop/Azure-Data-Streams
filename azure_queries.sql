/* Query 1:
Show the total “Amount” of “Type = 0” transactions at “ATM Code = 21” of the last 10 minutes. Repeat as new events
keep flowing in (use a sliding window).*/

SELECT SUM(Amount)
FROM [YourInputAlias] TIMESTAMP BY EventEnqueuedUtcTime
WHERE ATMCode=21 AND Type=0
GROUP BY SlidingWindow(minute,10)


/* Query 2:
Show the total “Amount” of “Type = 1” transactions at “ATM Code = 21” of the last hour. Repeat once every hour
  (use a tumbling window).*/

SELECT SUM(Amount)
FROM [YourInputAlias] TIMESTAMP BY EventEnqueuedUtcTime
WHERE ATMCode=21 AND Type=1
GROUP BY TumblingWindow(hour,1)

/* Query 3:
 Show the total “Amount” of “Type = 1” transactions at “ATM Code = 21” of the last hour. Repeat once every 30 minutes (use a hopping window).
 */

SELECT SUM(Amount)
FROM [YourInputAlias] TIMESTAMP BY EventEnqueuedUtcTime
WHERE ATMCode=21 AND Type=1
GROUP BY HoppingWindow (minute,60,30)

/* Query 4:
Show the total “Amount” of “Type = 1” transactions per “ATM Code” of the last
one hour (use a sliding window). */

SELECT SUM(Amount)
FROM [YourInputAlias] TIMESTAMP BY EventEnqueuedUtcTime
WHERE Type=1
GROUP BY ATMCode, SlidingWindow(hour,1)


/* Query 5:
Show the total “Amount” of “Type = 1” transactions per “Area Code” of the last hour.
Repeat once every hour (use a tumbling window). */

SELECT
    [atmref].[area_code] AS AreaCode,
    SUM([input].[Amount]) AS TotalAmount
FROM
    input TIMESTAMP BY EventEnqueuedUtcTime
LEFT JOIN
    [atmref] ON [input].[ATMCode] = [atmref].[atm_code]
WHERE
    [input].[type] = 1
GROUP BY
    [atmref].[area_code],
    TumblingWindow(hour, 1)


/* Query 6:
Show the total “Amount” per ATM’s “City” and Customer’s “Gender” of the last hour.
Repeat once every hour (use a tumbling window). */

SELECT
    [atmref].[area_code] AS AreaCode,
    SUM([input].[Amount]) AS TotalAmount
FROM
    input TIMESTAMP BY EventEnqueuedUtcTime
LEFT JOIN
    [atmref] ON [input].[ATMCode] = [atmref].[atm_code]
WHERE
    [input].[type] = 1
GROUP BY
    [atmref].[area_code],
    TumblingWindow(hour, 1)



/* Query 7:
Alert (SELECT “1”) if a Customer has performed two transactions of “Type = 1”
in a window of an hour (use a sliding window). */

SELECT
    1 AS Alert, [input].[CardNumber]
FROM
    [input] TIMESTAMP BY EventEnqueuedUtcTime
WHERE
    [input].[Type] = 1
GROUP BY
    [input].[CardNumber],
    SlidingWindow(hour, 1)
HAVING
    COUNT(*) >= 2

/*
Query 8:
Alert (SELECT “1”) if the “Area Code” of the ATM of the transaction is not the same
as the “Area Code” of the “Card Number” (Customer’s Area Code) - (use a sliding window) */

SELECT 1 AS Alert, [atmref].[area_code], [customerref].[card_number]
FROM input TIMESTAMP BY EventEnqueuedUtcTime
LEFT JOIN
    [customerref] ON [customerref].[card_number] = [input].[CardNumber]
LEFT JOIN
    [atmref] ON [atmref].[atm_code] = [input].[ATMCode]
WHERE
    [atmref].[area_code] <> [customerref].[area_code]

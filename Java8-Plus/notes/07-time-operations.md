# Time Operations in Java (java.time API)

## Overview

Java 8 introduced the `java.time` package as a modern replacement for the legacy `java.util.Date` and `java.util.Calendar` classes. It provides a comprehensive and thread-safe API for date and time operations.

## Why java.time?

### Problems with Legacy Classes

```java
// Legacy java.util.Date - Problems:
Date date = new Date();  // 1970-01-01 + milliseconds
date.setYear(2024);      // Deprecated!
date.setMonth(0);        // 0-based month (confusing!)

// Not thread-safe
SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
// DANGER: Can't share SimpleDateFormat across threads!

// Mutable - can be changed after creation
Date now = new Date();
// ...
now.setTime(0);  // Original object modified!
```

### Benefits of java.time

- ✅ Immutable and thread-safe
- ✅ Clear separation of concerns
- ✅ Fluent API design
- ✅ ISO 8601 standard support
- ✅ Better performance
- ✅ Timezone handling

## Core Classes

### 1. LocalDate

```java
import java.time.LocalDate;
import java.time.Month;

public class LocalDateExample {

    public static void main(String[] args) {
        // Current date
        LocalDate today = LocalDate.now();
        System.out.println(today);  // 2024-10-25

        // Specific date
        LocalDate specificDate = LocalDate.of(2024, Month.OCTOBER, 25);
        LocalDate anotherDate = LocalDate.of(2024, 10, 25);

        // Parse from string
        LocalDate parsed = LocalDate.parse("2024-10-25");

        // Date arithmetic
        LocalDate tomorrow = today.plusDays(1);
        LocalDate nextMonth = today.plusMonths(1);
        LocalDate nextYear = today.plusYears(1);

        // Negative operations
        LocalDate yesterday = today.minusDays(1);

        // Information
        int dayOfMonth = today.getDayOfMonth();
        int monthValue = today.getMonthValue();
        int year = today.getYear();
        DayOfWeek dayOfWeek = today.getDayOfWeek();
        int dayOfYear = today.getDayOfYear();

        // Comparisons
        boolean isAfter = today.isAfter(yesterday);
        boolean isBefore = today.isBefore(tomorrow);
        boolean isLeapYear = Year.of(2024).isLeap();

        // First and last day of month
        LocalDate firstOfMonth = today.withDayOfMonth(1);
        LocalDate lastOfMonth = today.with(TemporalAdjusters.lastDayOfMonth());
    }
}
```

### 2. LocalTime

```java
import java.time.LocalTime;

public class LocalTimeExample {

    public static void main(String[] args) {
        // Current time
        LocalTime now = LocalTime.now();
        System.out.println(now);  // 14:30:45.123

        // Specific time
        LocalTime specificTime = LocalTime.of(14, 30, 45);
        LocalTime withNanos = LocalTime.of(14, 30, 45, 123456789);

        // Parse from string
        LocalTime parsed = LocalTime.parse("14:30:45");

        // Time arithmetic
        LocalTime later = now.plusHours(2);
        LocalTime soonLater = now.plusMinutes(30);
        LocalTime nextSecond = now.plusSeconds(1);

        // Information
        int hour = now.getHour();
        int minute = now.getMinute();
        int second = now.getSecond();
        int nano = now.getNano();

        // Comparisons
        boolean isAfter = now.isAfter(LocalTime.NOON);
        boolean isBefore = now.isBefore(LocalTime.MIDNIGHT);

        // Constants
        LocalTime noon = LocalTime.NOON;
        LocalTime midnight = LocalTime.MIDNIGHT;
    }
}
```

### 3. LocalDateTime

```java
import java.time.LocalDateTime;

public class LocalDateTimeExample {

    public static void main(String[] args) {
        // Current date and time
        LocalDateTime now = LocalDateTime.now();
        System.out.println(now);  // 2024-10-25T14:30:45.123

        // Specific date and time
        LocalDateTime specific = LocalDateTime.of(2024, 10, 25, 14, 30, 45);

        // From LocalDate and LocalTime
        LocalDate date = LocalDate.now();
        LocalTime time = LocalTime.now();
        LocalDateTime dateTime = LocalDateTime.of(date, time);

        // Parse from string
        LocalDateTime parsed = LocalDateTime.parse("2024-10-25T14:30:45");

        // Arithmetic
        LocalDateTime future = now.plusDays(1).plusHours(2);

        // Extracting components
        LocalDate extractedDate = now.toLocalDate();
        LocalTime extractedTime = now.toLocalTime();

        // Comparisons
        boolean isAfter = now.isAfter(LocalDateTime.MIN);
        boolean isBefore = now.isBefore(LocalDateTime.MAX);
    }
}
```

### 4. ZonedDateTime

```java
import java.time.ZonedDateTime;
import java.time.ZoneId;
import java.time.ZoneOffset;

public class ZonedDateTimeExample {

    public static void main(String[] args) {
        // Current time in default zone
        ZonedDateTime nowDefault = ZonedDateTime.now();
        System.out.println(nowDefault);  // 2024-10-25T14:30:45.123+02:00[Europe/Athens]

        // Current time in specific zone
        ZonedDateTime nowUtc = ZonedDateTime.now(ZoneId.of("UTC"));
        ZonedDateTime nowNewYork = ZonedDateTime.now(ZoneId.of("America/New_York"));
        ZonedDateTime nowTokyo = ZonedDateTime.now(ZoneId.of("Asia/Tokyo"));

        // From LocalDateTime
        LocalDateTime local = LocalDateTime.now();
        ZonedDateTime zoned = local.atZone(ZoneId.of("Europe/London"));

        // Specific date and time
        ZonedDateTime specific = ZonedDateTime.of(2024, 10, 25, 14, 30, 45, 0,
            ZoneId.of("America/Los_Angeles"));

        // Convert between zones
        ZoneId toZone = ZoneId.of("Asia/Tokyo");
        ZonedDateTime converted = nowNewYork.withZoneSameInstant(toZone);

        // Get offset from UTC
        ZoneOffset offset = nowDefault.getOffset();
        System.out.println(offset);  // +02:00
    }
}
```

### 5. Instant

```java
import java.time.Instant;
import java.time.Duration;

public class InstantExample {

    public static void main(String[] args) {
        // Current instant (UTC)
        Instant now = Instant.now();
        System.out.println(now);  // 2024-10-25T12:30:45.123Z

        // Specific instant
        Instant specific = Instant.ofEpochSecond(0);  // Unix epoch

        // From ZonedDateTime
        ZonedDateTime zoned = ZonedDateTime.now();
        Instant instant = zoned.toInstant();

        // Convert to ZonedDateTime
        ZonedDateTime backToZoned = instant.atZone(ZoneId.of("UTC"));

        // Comparisons
        boolean isAfter = now.isAfter(Instant.EPOCH);

        // Time measurement
        Instant start = Instant.now();
        // ... do work ...
        Instant end = Instant.now();
        Duration elapsed = Duration.between(start, end);
    }
}
```

## Duration and Period

### Duration - Time-Based

```java
import java.time.Duration;
import java.time.LocalDateTime;

public class DurationExample {

    public static void main(String[] args) {
        // Create duration
        Duration oneDay = Duration.ofDays(1);
        Duration twoHours = Duration.ofHours(2);
        Duration thirtyMinutes = Duration.ofMinutes(30);
        Duration fiveSeconds = Duration.ofSeconds(5);
        Duration nanos = Duration.ofNanos(1000);

        // Between two instants
        Instant start = Instant.now();
        // ... do work ...
        Instant end = Instant.now();
        Duration elapsed = Duration.between(start, end);

        // Between two temporal objects
        LocalDateTime from = LocalDateTime.now();
        LocalDateTime to = from.plusDays(5);
        Duration difference = Duration.between(from, to);

        // Arithmetic
        Duration longer = oneDay.plus(twoHours);
        Duration shorter = longer.minus(thirtyMinutes);
        Duration doubled = oneDay.multipliedBy(2);

        // Information
        long days = elapsed.toDays();
        long hours = elapsed.toHours();
        long minutes = elapsed.toMinutes();
        long seconds = elapsed.getSeconds();
        int nanosPart = elapsed.getNano();

        // Comparisons
        boolean isLonger = elapsed.compareTo(oneDay) > 0;
        boolean isNegative = elapsed.isNegative();
        boolean isZero = elapsed.isZero();
    }
}
```

### Period - Date-Based

```java
import java.time.Period;
import java.time.LocalDate;

public class PeriodExample {

    public static void main(String[] args) {
        // Create period
        Period oneYear = Period.ofYears(1);
        Period twoMonths = Period.ofMonths(2);
        Period threeWeeks = Period.ofWeeks(3);
        Period fourDays = Period.ofDays(4);

        // Combined
        Period combined = Period.of(1, 2, 4);  // 1 year, 2 months, 4 days

        // Between two dates
        LocalDate from = LocalDate.of(2024, 1, 1);
        LocalDate to = LocalDate.of(2025, 3, 15);
        Period between = Period.between(from, to);
        System.out.println(between);  // P1Y2M14D

        // Arithmetic
        LocalDate date = LocalDate.now();
        LocalDate futureDate = date.plus(oneYear);
        LocalDate pastDate = date.minus(twoMonths);

        // Information
        int years = between.getYears();
        int months = between.getMonths();
        int days = between.getDays();

        // Comparisons
        boolean isNegative = between.isNegative();
        boolean isZero = between.isZero();
    }
}
```

## Formatting and Parsing

### DateTimeFormatter

```java
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.time.format.FormatStyle;

public class FormattingExample {

    public static void main(String[] args) {
        LocalDateTime now = LocalDateTime.now();

        // Predefined formatters
        DateTimeFormatter iso = DateTimeFormatter.ISO_LOCAL_DATE_TIME;
        System.out.println(iso.format(now));  // 2024-10-25T14:30:45.123

        // Style-based formatters
        DateTimeFormatter shortStyle = DateTimeFormatter.ofLocalizedDateTime(
            FormatStyle.SHORT
        );
        DateTimeFormatter mediumStyle = DateTimeFormatter.ofLocalizedDateTime(
            FormatStyle.MEDIUM
        );
        DateTimeFormatter longStyle = DateTimeFormatter.ofLocalizedDateTime(
            FormatStyle.LONG
        );

        // Custom formatter
        DateTimeFormatter customFormatter = DateTimeFormatter.ofPattern(
            "dd/MM/yyyy HH:mm:ss"
        );
        System.out.println(customFormatter.format(now));  // 25/10/2024 14:30:45

        // Parsing
        String dateString = "25/10/2024 14:30:45";
        LocalDateTime parsed = LocalDateTime.parse(dateString, customFormatter);

        // Pattern examples
        DateTimeFormatter patterns[] = {
            DateTimeFormatter.ofPattern("yyyy-MM-dd"),           // 2024-10-25
            DateTimeFormatter.ofPattern("MM/dd/yyyy"),           // 10/25/2024
            DateTimeFormatter.ofPattern("dd-MMM-yyyy"),          // 25-Oct-2024
            DateTimeFormatter.ofPattern("EEEE, MMMM d, yyyy"),  // Thursday, October 25, 2024
            DateTimeFormatter.ofPattern("HH:mm:ss"),             // 14:30:45
            DateTimeFormatter.ofPattern("hh:mm:ss a"),           // 02:30:45 PM
        };
    }
}
```

## Working with Zones

### Zone Operations

```java
import java.time.ZoneId;
import java.time.ZonedDateTime;
import java.util.Set;

public class ZoneExample {

    public static void main(String[] args) {
        // Get all available zones
        Set<String> zones = ZoneId.getAvailableZoneIds();
        zones.forEach(System.out::println);

        // Get default zone
        ZoneId defaultZone = ZoneId.systemDefault();

        // Common zones
        ZoneId utc = ZoneId.of("UTC");
        ZoneId london = ZoneId.of("Europe/London");
        ZoneId newYork = ZoneId.of("America/New_York");
        ZoneId tokyo = ZoneId.of("Asia/Tokyo");

        // Convert LocalDateTime to specific zone
        LocalDateTime local = LocalDateTime.now();
        ZonedDateTime zoned = local.atZone(london);

        // Convert between zones
        ZonedDateTime tokyoTime = zoned.withZoneSameInstant(tokyo);

        // Daylight saving time handling
        ZonedDateTime beforeDST = ZonedDateTime.of(2024, 3, 10, 1, 30, 0, 0,
            ZoneId.of("America/New_York"));
        ZonedDateTime afterDST = beforeDST.plusHours(2);
    }
}
```

## Practical Examples

### Example 1: Age Calculation

```java
public class AgeCalculator {

    public static int calculateAge(LocalDate birthDate, LocalDate currentDate) {
        return Period.between(birthDate, currentDate).getYears();
    }

    public static void main(String[] args) {
        LocalDate birthDate = LocalDate.of(1990, 5, 15);
        LocalDate today = LocalDate.now();

        int age = calculateAge(birthDate, today);
        System.out.println("Age: " + age);
    }
}
```

### Example 2: Business Hours Calculation

```java
public class BusinessHoursCalculator {
    private static final int WORK_START = 9;   // 9 AM
    private static final int WORK_END = 17;    // 5 PM
    private static final ZoneId ZONE = ZoneId.of("America/New_York");

    public static Duration calculateBusinessHours(
            LocalDateTime from, LocalDateTime to) {

        Duration total = Duration.ZERO;
        LocalDateTime current = from;

        while (current.isBefore(to)) {
            if (isWorkDay(current) && isWorkHours(current)) {
                LocalDateTime nextHour = current.plusHours(1);
                LocalDateTime endOfDay = current.toLocalDate()
                    .atTime(WORK_END, 0);

                LocalDateTime until = to.isBefore(endOfDay) ? to : endOfDay;
                total = total.plus(Duration.between(current, until));
                current = until;
            } else {
                current = current.plusHours(1);
            }
        }

        return total;
    }

    private static boolean isWorkDay(LocalDateTime dateTime) {
        DayOfWeek day = dateTime.getDayOfWeek();
        return day != DayOfWeek.SATURDAY && day != DayOfWeek.SUNDAY;
    }

    private static boolean isWorkHours(LocalDateTime dateTime) {
        int hour = dateTime.getHour();
        return hour >= WORK_START && hour < WORK_END;
    }
}
```

### Example 3: Recurring Event Scheduling

```java
public class EventScheduler {

    public static List<LocalDateTime> getNextOccurrences(
            LocalDateTime startTime, Period interval, int count) {

        List<LocalDateTime> occurrences = new ArrayList<>();
        LocalDateTime current = startTime;

        for (int i = 0; i < count; i++) {
            occurrences.add(current);
            current = current.plus(interval);
        }

        return occurrences;
    }

    public static void main(String[] args) {
        LocalDateTime startTime = LocalDateTime.of(2024, 10, 25, 10, 0);
        Period interval = Period.ofDays(7);  // Weekly

        List<LocalDateTime> meetings = getNextOccurrences(startTime, interval, 4);
        meetings.forEach(System.out::println);
    }
}
```

### Example 4: Timeout with Deadline

```java
public class DeadlineManager {

    public static long getTimeUntilDeadline(ZonedDateTime deadline) {
        Duration time = Duration.between(ZonedDateTime.now(), deadline);

        if (time.isNegative()) {
            return -1;  // Deadline passed
        }

        return time.getSeconds();
    }

    public static void main(String[] args) {
        ZonedDateTime deadline = ZonedDateTime.now().plusDays(3);
        long secondsLeft = getTimeUntilDeadline(deadline);

        long days = secondsLeft / 86400;
        long hours = (secondsLeft % 86400) / 3600;
        long minutes = (secondsLeft % 3600) / 60;

        System.out.printf("%d days, %d hours, %d minutes left%n",
            days, hours, minutes);
    }
}
```

## Comparison Table

| Class | Purpose | Timezone Aware | Mutable |
|-------|---------|----------------|---------|
| LocalDate | Date only | No | No |
| LocalTime | Time only | No | No |
| LocalDateTime | Date + Time | No | No |
| ZonedDateTime | Date + Time + Zone | Yes | No |
| Instant | Machine time (UTC) | Yes | No |
| Duration | Time amount | No | No |
| Period | Date amount | No | No |

## Best Practices

- ✅ Always use `java.time` over legacy classes
- ✅ Use `LocalDateTime` for application logic
- ✅ Use `ZonedDateTime` when timezone matters
- ✅ Use `Instant` for machine-to-machine communication
- ✅ Use `Duration` for time measurements
- ✅ Use `Period` for date calculations
- ✅ Immutability ensures thread-safety
- ✅ ISO 8601 format for string representation
- ✅ Be aware of daylight saving time transitions
- ✅ Store dates in UTC, display in user's zone

## Common Pitfalls

```java
// WRONG - Creating mutable date
Date date = new Date();  // Deprecated and mutable!

// RIGHT - Using java.time immutable types
LocalDate date = LocalDate.now();

// WRONG - Forgetting timezone
ZonedDateTime time = LocalDateTime.now().atZone(ZoneId.systemDefault());

// RIGHT - Being explicit about timezone
ZonedDateTime time = ZonedDateTime.now(ZoneId.of("UTC"));

// WRONG - Losing precision
Date date = new Date();
SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
// Loses time information!

// RIGHT - Preserving precision
LocalDateTime dateTime = LocalDateTime.now();
DateTimeFormatter formatter = DateTimeFormatter.ISO_LOCAL_DATE_TIME;
// Keeps full precision
```

## Summary

The `java.time` package provides:
- ✅ Immutable, thread-safe date/time classes
- ✅ Clear separation between date, time, and timezone
- ✅ Fluent API for easy manipulation
- ✅ ISO 8601 standard compliance
- ✅ Comprehensive timezone support
- ✅ Better performance than legacy classes

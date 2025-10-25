# Real-World Java 8+ Coding Problems

Practical problems that demonstrate real-world usage of Java 8+ features.

---

## Problem 1: Filter and Collect Users

**Description:** Given a list of users, filter adults (age >= 18) and collect their names into a list.

**Input:**
```java
List<User> users = Arrays.asList(
    new User("Alice", 25),
    new User("Bob", 17),
    new User("Charlie", 30),
    new User("Diana", 16)
);
```

**Expected Output:**
```
[Alice, Charlie]
```

**Solution:**
```java
List<String> adultNames = users.stream()
    .filter(u -> u.getAge() >= 18)
    .map(User::getName)
    .collect(Collectors.toList());
```

**Difficulty:** Basic
**Tags:** #filter #map #collect

---

## Problem 2: Calculate Total Price with Discount

**Description:** Calculate the total price of items in a shopping cart, applying a discount to items marked as "discounted".

**Input:**
```java
record Item(String name, double price, boolean discounted) {}

List<Item> items = Arrays.asList(
    new Item("Book", 15.00, false),
    new Item("Pen", 2.50, true),
    new Item("Notebook", 5.00, true)
);
```

**Expected Output:**
```
Total: 20.25
(Book: 15.00, Pen: 2.50 * 0.9 = 2.25, Notebook: 5.00 * 0.9 = 4.50)
```

**Solution:**
```java
double total = items.stream()
    .mapToDouble(item -> item.discounted() ? item.price() * 0.9 : item.price())
    .sum();

System.out.println("Total: " + total);
```

**Difficulty:** Intermediate
**Tags:** #mapToDouble #sum #conditional-logic

---

## Problem 3: Group Products by Category

**Description:** Group products by their category and count how many products are in each category.

**Input:**
```java
record Product(String name, String category, double price) {}

List<Product> products = Arrays.asList(
    new Product("Laptop", "Electronics", 1000),
    new Product("Mouse", "Electronics", 25),
    new Product("Desk", "Furniture", 200),
    new Product("Chair", "Furniture", 150),
    new Product("Keyboard", "Electronics", 75)
);
```

**Expected Output:**
```
Electronics: 3
Furniture: 2
```

**Solution:**
```java
Map<String, Long> categoryCount = products.stream()
    .collect(Collectors.groupingBy(
        Product::category,
        Collectors.counting()
    ));

categoryCount.forEach((category, count) ->
    System.out.println(category + ": " + count)
);
```

**Difficulty:** Intermediate
**Tags:** #groupingBy #collectors #map

---

## Problem 4: Find Most Expensive Product

**Description:** Find the most expensive product in a list.

**Input:**
```java
List<Product> products = Arrays.asList(
    new Product("Laptop", 1000),
    new Product("Mouse", 25),
    new Product("Keyboard", 75)
);
```

**Expected Output:**
```
Optional[Product(name=Laptop, price=1000.0)]
```

**Solution:**
```java
Optional<Product> mostExpensive = products.stream()
    .max(Comparator.comparingDouble(Product::price));

mostExpensive.ifPresent(p ->
    System.out.println("Most expensive: " + p.name() + " - $" + p.price())
);
```

**Difficulty:** Intermediate
**Tags:** #max #comparator #optional

---

## Problem 5: Remove Duplicates and Sort

**Description:** Remove duplicate names from a list and sort them alphabetically.

**Input:**
```java
List<String> names = Arrays.asList("Alice", "Bob", "Alice", "Charlie", "Bob", "Diana");
```

**Expected Output:**
```
[Alice, Bob, Charlie, Diana]
```

**Solution:**
```java
List<String> unique = names.stream()
    .distinct()
    .sorted()
    .collect(Collectors.toList());
```

**Difficulty:** Basic
**Tags:** #distinct #sorted #collect

---

## Problem 6: Create a Map from a List

**Description:** Create a map where the key is the person's name and the value is their age.

**Input:**
```java
record Person(String name, int age) {}

List<Person> people = Arrays.asList(
    new Person("Alice", 25),
    new Person("Bob", 30),
    new Person("Charlie", 28)
);
```

**Expected Output:**
```
{Alice=25, Bob=30, Charlie=28}
```

**Solution:**
```java
Map<String, Integer> nameToAge = people.stream()
    .collect(Collectors.toMap(
        Person::name,
        Person::age
    ));
```

**Difficulty:** Intermediate
**Tags:** #toMap #collectors

---

## Problem 7: Partition Numbers

**Description:** Partition numbers into even and odd.

**Input:**
```java
List<Integer> numbers = Arrays.asList(1, 2, 3, 4, 5, 6, 7, 8, 9, 10);
```

**Expected Output:**
```
Even: [2, 4, 6, 8, 10]
Odd: [1, 3, 5, 7, 9]
```

**Solution:**
```java
Map<Boolean, List<Integer>> partitioned = numbers.stream()
    .collect(Collectors.partitioningBy(n -> n % 2 == 0));

System.out.println("Even: " + partitioned.get(true));
System.out.println("Odd: " + partitioned.get(false));
```

**Difficulty:** Intermediate
**Tags:** #partitioningBy #collectors

---

## Problem 8: FlatMap - Flatten Nested Lists

**Description:** Flatten a list of lists into a single list.

**Input:**
```java
List<List<Integer>> nestedList = Arrays.asList(
    Arrays.asList(1, 2, 3),
    Arrays.asList(4, 5),
    Arrays.asList(6, 7, 8, 9)
);
```

**Expected Output:**
```
[1, 2, 3, 4, 5, 6, 7, 8, 9]
```

**Solution:**
```java
List<Integer> flattened = nestedList.stream()
    .flatMap(List::stream)
    .collect(Collectors.toList());
```

**Difficulty:** Intermediate
**Tags:** #flatmap #flatten

---

## Problem 9: Check if All Elements Match Condition

**Description:** Check if all students have passed (score >= 50).

**Input:**
```java
record Student(String name, int score) {}

List<Student> students = Arrays.asList(
    new Student("Alice", 75),
    new Student("Bob", 65),
    new Student("Charlie", 40)
);
```

**Expected Output:**
```
false (Charlie didn't pass)
```

**Solution:**
```java
boolean allPassed = students.stream()
    .allMatch(s -> s.score() >= 50);

System.out.println("All passed: " + allPassed);
```

**Difficulty:** Basic
**Tags:** #allMatch #predicate

---

## Problem 10: Calculate Statistics

**Description:** Calculate sum, average, min, and max of a list of numbers.

**Input:**
```java
List<Integer> numbers = Arrays.asList(10, 25, 15, 30, 20, 5);
```

**Expected Output:**
```
Sum: 105
Average: 17.5
Min: 5
Max: 30
```

**Solution:**
```java
IntSummaryStatistics stats = numbers.stream()
    .mapToInt(Integer::intValue)
    .summaryStatistics();

System.out.println("Sum: " + stats.getSum());
System.out.println("Average: " + stats.getAverage());
System.out.println("Min: " + stats.getMin());
System.out.println("Max: " + stats.getMax());
```

**Difficulty:** Intermediate
**Tags:** #mapToInt #summaryStatistics

---

## Problem 11: Find Common Elements

**Description:** Find elements that appear in both lists.

**Input:**
```java
List<Integer> list1 = Arrays.asList(1, 2, 3, 4, 5);
List<Integer> list2 = Arrays.asList(3, 4, 5, 6, 7);
```

**Expected Output:**
```
[3, 4, 5]
```

**Solution:**
```java
List<Integer> common = list1.stream()
    .filter(list2::contains)
    .collect(Collectors.toList());
```

**Difficulty:** Intermediate
**Tags:** #filter #contains

---

## Problem 12: Handle Optional Values

**Description:** Get user email with a default value if not present.

**Input:**
```java
record User(String name, Optional<String> email) {}

User user1 = new User("Alice", Optional.of("alice@example.com"));
User user2 = new User("Bob", Optional.empty());
```

**Expected Output:**
```
Alice's email: alice@example.com
Bob's email: no-email@example.com
```

**Solution:**
```java
Stream.of(user1, user2)
    .forEach(u -> {
        String email = u.email()
            .orElse("no-email@example.com");
        System.out.println(u.name() + "'s email: " + email);
    });
```

**Difficulty:** Intermediate
**Tags:** #optional #orElse

---

## Challenge Problems

### Challenge 1: Word Frequency Counter

**Description:** Count the frequency of each word in a text (case-insensitive).

**Input:**
```
"java java stream stream api java"
```

**Expected Output:**
```
java: 3
stream: 2
api: 1
```

**Difficulty:** Advanced
**Tags:** #groupingBy #frequency

---

### Challenge 2: Top N Expensive Items

**Description:** Get the top 3 most expensive items from a list.

**Input:**
```
List of products with prices
```

**Expected Output:**
```
Top 3 most expensive items
```

**Difficulty:** Advanced
**Tags:** #sorted #limit #reversed

---

### Challenge 3: Parallel Stream Processing

**Description:** Process a large list using parallel streams for better performance.

**Difficulty:** Advanced
**Tags:** #parallel-streams #performance

---

## Next Steps

1. Solve all basic problems first
2. Move to intermediate problems
3. Attempt challenge problems
4. Combine multiple operations for complex scenarios


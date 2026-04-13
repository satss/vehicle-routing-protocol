import sys

from annealing.simulated_annealing import distances
def greedy_tsp(start_city):
    print(distances)
    num_cities = len(distances)
    unvisited_cities = set(range(num_cities))
    current_city = start_city
    route = [current_city]
    unvisited_cities.remove(current_city)
    total_distance = 0

    while unvisited_cities:
        nearest_city = None
        min_distance = sys.maxsize

        for city in unvisited_cities:
            distance = distances[current_city][city]
            if distance < min_distance:
                min_distance = distance
                nearest_city = city

        route.append(nearest_city)
        total_distance += min_distance
        current_city = nearest_city
        if nearest_city is not None:
            unvisited_cities.remove(nearest_city)

    # Return to the starting city
    total_distance += distances[current_city][start_city]
    route.append(start_city)

    return route, total_distance

start_city = "A"  # Start from city A
route, dist = greedy_tsp(start_city)
print(route)
print(dist)
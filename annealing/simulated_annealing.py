import math
import random

distances = {
    "A": {"A": 0, "B": 99, "C": 44, "D": 22, "E": 215, "F": 1154},
    "B": {"A": 99, "B": 0, "C": 103, "D": 14, "E": 225, "F": 1438},
    "C": {"A": 44, "B": 103, "C": 0, "D": 39, "E": 253, "F": 1477},
    "D": {"A": 22, "B": 14, "C": 39, "D": 0, "E": 236, "F": 1474},
    "E": {"A": 215, "B": 225, "C": 253, "D": 236, "E": 0, "F": 1719},
    "F": {"A": 1154, "B": 1438, "C": 1477, "D": 1474, "E": 1719, "F": 0},
}


initial_temperature = 100

cooling_rate = 0.9
stopping_temperature = 2

# not optimal iteration can bring the value up or down
iterations = 10000000


def generate_neighbour(route: list) -> list:
    index1 = random.randint(0, len(route) - 1)
    index2 = random.randint(0, len(route) - 1)
    while index1 == index2:
        index2 = random.randint(0, len(route) - 1)
    copy_route = route.copy()
    copy_route[index1], copy_route[index2] = copy_route[index2], copy_route[index1]
    return copy_route


def calculate_distance(given_route: list) -> int:
    distance = 0
    for i in range(len(given_route) - 1):
        distance = distance + distances[given_route[i]][given_route[i + 1]]
    return distance


def simulated_annealing_algorithm(
    initial_temperature: int,
    cooling_rate: float,
    stopping_temperature: int,
    iterations: int,
):
    current_route = list(distances.keys())
    print(current_route)
    current_distance = calculate_distance(current_route)
    best_route = current_route.copy()
    best_distance = current_distance
    temperature = initial_temperature

    for i in range(iterations):
        new_route = generate_neighbour(current_route)
        neighbor_distance = calculate_distance(new_route)
        delta_e = neighbor_distance - current_distance

        if delta_e < 0:
            current_route = new_route.copy()
            current_distance = neighbor_distance
            if current_distance < best_distance:
                best_route = new_route.copy()
                best_distance = current_distance
        else:
            probability = math.exp(-delta_e / temperature)

            if random.random() < probability:
                current_route = new_route.copy()
                current_distance = neighbor_distance
        temperature *= cooling_rate
        if temperature < stopping_temperature:
            break
    return best_route, best_distance


route, distance = simulated_annealing_algorithm(
    initial_temperature, cooling_rate, stopping_temperature, iterations
)
print(route)
print(distance)

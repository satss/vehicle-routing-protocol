import random
import sys

from annealing.simulated_annealing import distances, calculate_distance, generate_neighbour


def tabu_search():
    current_route = list(distances.keys())
    current_distance = calculate_distance(current_route)
    best_route = current_route.copy()
    best_distance = current_distance
    tabu_list = []

    for i in range(2):
        neighbour_moves = [generate_neighbour(current_route) for _ in range(2)]
        best_neighbour = None
        best_distance = sys.maxsize
        for neighbour in neighbour_moves:
            neighbour_distance = calculate_distance(neighbour)
            move = tuple(sorted((current_route.index(city) for city in neighbour)))

            if move not in tabu_list:
                if neighbour_distance < best_distance:
                    best_neighbour = neighbour
                    best_distance = neighbour_distance
            elif random.random() < 100:
                if neighbour_distance < best_distance:
                    best_neighbour = neighbour
                    best_distance = neighbour_distance


        if best_neighbour is not None:
            current_route = best_neighbour
            current_distance= best_distance
            move = tuple(sorted((current_route.index(city) for city in best_neighbour)))
            tabu_list.append(move)
            if len(tabu_list) > 2:
                tabu_list.pop(0)
            if current_distance < best_distance:
                best_route = current_route.copy()
                best_distance = current_distance


    return best_route, best_distance





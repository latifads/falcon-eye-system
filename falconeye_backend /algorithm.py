# algorithm.py
# Falcon SAR Search Algorithm

import math

# ==========================================
# GRID CONFIG
# ==========================================
CELL_SIZE = 5000.0

# ==========================================
# WALKING SPEEDS (km/h)
# ==========================================
WALKING_SPEEDS = {

    ("male", "child"): 4.5,
    ("female", "child"): 4.2,

    ("male", "adult"): 5.15,
    ("female", "adult"): 4.8,

    ("male", "elderly"): 4.0,
    ("female", "elderly"): 3.5,
}

# ==========================================
# SPEED ESTIMATION
# ==========================================
def get_speed(age_range, gender, vehicle):

    return WALKING_SPEEDS.get(
        (gender.lower(), age_range.lower()),
        4.5
    )

# ==========================================
# SEARCH RADIUS
# ==========================================
def compute_search_radius(
    hours_missing,
    age_range,
    gender,
    vehicle
):

    speed_kmh = get_speed(
        age_range,
        gender,
        vehicle
    )

    import math

    radius_km = (
    speed_kmh *
    math.sqrt(hours_missing)
)

    if vehicle.lower() == "car":
     radius_km += 5


    return radius_km * 1000


     # 5 km
# ==========================================
# CREATE PROBABILITY GRID
# ==========================================
def create_grid(radius, cell_size=CELL_SIZE):

    grid_w = int((radius * 2) / cell_size)
    grid_h = int((radius * 2) / cell_size)

    grid = []

    center_x = grid_w // 2
    center_y = grid_h // 2

    for y in range(grid_h):

        row = []

        for x in range(grid_w):

            distance = math.sqrt(
                (x - center_x) ** 2 +
                (y - center_y) ** 2
            )

            max_distance = math.sqrt(
                center_x ** 2 +
                center_y ** 2
            )

            probability = 1.0 - (
                distance / max_distance
            )

            row.append({

                "visited": False,

                "score": round(
                    probability,
                    2
                ),

                "evidence": [],

                "color": "red"
            })

        grid.append(row)

    return grid, grid_w, grid_h

# ==========================================
# DRONE TO GRID
# ==========================================
def drone_to_grid(
    drone_x,
    drone_y,
    radius,
    cell_size=CELL_SIZE
):

    gx = int((drone_x + radius) / cell_size)
    gy = int((drone_y + radius) / cell_size)

    return gx, gy

# ==========================================
# DETERMINE DIRECTION
# ==========================================
def bbox_direction(
    x1,
    x2,
    frame_w
):

    cx = (x1 + x2) / 2.0

    if cx < frame_w / 3:
        return "LEFT"

    elif cx > 2 * frame_w / 3:
        return "RIGHT"

    return "FORWARD"

# ==========================================
# DIRECTION RECOMMENDATION
# ==========================================
def decide_direction(evidence_list):

    if not evidence_list:
        return "SEARCHING", 0.0

    direction_votes = {

        "LEFT": 0,
        "RIGHT": 0,
        "FORWARD": 0
    }

    weights = {

        "person": 5,
        "footprint": 3,
        "vehicle": 2
    }

    for e in evidence_list:

        score = (
            weights[e["type"]] *
            e["confidence"]
        )

        direction_votes[
            e["direction"]
        ] += score

    best_direction = max(
        direction_votes,
        key=direction_votes.get
    )

    confidence = direction_votes[
        best_direction
    ]

    return best_direction, round(confidence, 2)

# ==========================================
# PROPAGATE PROBABILITY
# ==========================================
def propagate_direction(
    grid,
    direction,
    x,
    y,
    grid_w,
    grid_h
):

    propagation_strength = 0.5

    if direction == "RIGHT":

        for i in range(1, 6):

            nx = x + i

            if 0 <= nx < grid_w:

                grid[y][nx]["score"] += (
                    propagation_strength / i
                )

    elif direction == "LEFT":

        for i in range(1, 6):

            nx = x - i

            if 0 <= nx < grid_w:

                grid[y][nx]["score"] += (
                    propagation_strength / i
                )

    elif direction == "FORWARD":

        for i in range(1, 6):

            ny = y + i

            if 0 <= ny < grid_h:

                grid[ny][x]["score"] += (
                    propagation_strength / i
                )

# ==========================================
# UPDATE GRID COLORS
# ==========================================
def update_grid_colors(
    grid,
    grid_w,
    grid_h
):

    for y in range(grid_h):

        for x in range(grid_w):

            cell = grid[y][x]

            score = cell["score"]

            if cell["visited"]:

                cell["color"] = "green"

            elif score > 1.2:

                cell["color"] = "blue"

            elif score > 0.8:

                cell["color"] = "orange"

            elif score > 0.5:

                cell["color"] = "yellow"

            else:

                cell["color"] = "red"

# ==========================================
# SIMPLIFY GRID
# ==========================================
def simplify_grid(grid):

    simple_grid = []

    for row in grid:

        simple_row = []

        for cell in row:

            simple_row.append(
                cell["color"]
            )

        simple_grid.append(
            simple_row
        )

    return simple_grid
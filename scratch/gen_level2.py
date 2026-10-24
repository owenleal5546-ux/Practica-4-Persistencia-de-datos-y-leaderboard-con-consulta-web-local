import re

def pack_coords(x, y):
    ux = x & 0xFFFF
    uy = y & 0xFFFF
    return (uy << 16) | ux

tiles_dict = {}

def add_tile(x, y, s, a):
    tiles_dict[(x, y)] = (s, a)

def add_ground(start_x, end_x, surface_y=11, depth=4):
    for x in range(start_x, end_x + 1):
        if x == start_x:
            add_tile(x, surface_y, 458752, 6)
        elif x == end_x:
            add_tile(x, surface_y, 655360, 6)
        else:
            add_tile(x, surface_y, 589824 if x % 2 == 0 else 524288, 3)
        
        for d in range(1, depth):
            y = surface_y + d
            if x == start_x:
                add_tile(x, y, 458752, 6)
            elif x == end_x:
                add_tile(x, y, 655360, 6)
            else:
                add_tile(x, y, 524288 if x % 2 == 0 else 589824, 4 if d % 2 == 1 else 5)

def add_floating(start_x, end_x, y):
    for x in range(start_x, end_x + 1):
        if x == start_x:
            add_tile(x, y, 196608, 0)
        elif x == end_x:
            add_tile(x, y, 458752, 6)
        else:
            mid_s = [262144, 327680, 393216][(x - start_x) % 3]
            add_tile(x, y, mid_s, 0)

# Build terrain layout for Nivel 2
add_ground(0, 73)
add_ground(83, 96)
add_ground(106, 125)
add_ground(135, 170)

add_floating(75, 77, 9)
add_floating(79, 81, 7)
add_floating(98, 103, 6)
add_floating(100, 102, 9)
add_floating(127, 129, 8)
add_floating(131, 133, 7)
add_floating(12, 17, 8)
add_floating(28, 34, 6)
add_floating(45, 52, 6)
add_floating(60, 65, 5)
add_floating(145, 152, 6)

packed_list = []
for (x, y), (s, a) in sorted(tiles_dict.items(), key=lambda k: (k[0][1], k[0][0])):
    p = pack_coords(x, y)
    packed_list.extend([str(p), str(s), str(a)])

tile_data_str = ', '.join(packed_list)

template = """[gd_scene format=3 uid="uid://nivel2scene001"]

[ext_resource type="PackedScene" uid="uid://cx5jsh6f7g6a0" path="res://World/parallax_background.tscn" id="1_uh6rm"]
[ext_resource type="Texture2D" uid="uid://12foa3wesyyn" path="res://World/Assets/tileset.png" id="1_wklou"]
[ext_resource type="Texture2D" uid="uid://cwpovsmkendrp" path="res://World/Assets/props/mushroom-brown.png" id="2_0etpo"]
[ext_resource type="PackedScene" uid="uid://crc2cyggi34kk" path="res://Player/player.tscn" id="2_3m2e0"]
[ext_resource type="Texture2D" uid="uid://doorv8d7wgeh2" path="res://World/Assets/props/mushroom-red.png" id="3_lpec2"]
[ext_resource type="Texture2D" uid="uid://ccierjag2o2ms" path="res://World/Assets/props/tree.png" id="4_20e5r"]
[ext_resource type="AudioStream" uid="uid://d3r51omyx66bq" path="res://Music/happywalking.ogg" id="4_gmwgb"]
[ext_resource type="PackedScene" uid="uid://8dbsyumfmwut" path="res://Enemies/Slug/Slug.tscn" id="5_o4885"]
[ext_resource type="PackedScene" uid="uid://cjcyy51wg5x2y" path="res://Enemies/Bee/bee.tscn" id="6_6l5e8"]
[ext_resource type="Texture2D" uid="uid://8jxt6ailv6ym" path="res://World/Assets/props/rock.png" id="6_f3vgq"]
[ext_resource type="PackedScene" uid="uid://dy4554uucwhh3" path="res://Enemies/PiranahPlant/piranah_plant.tscn" id="7_uqbqm"]
[ext_resource type="PackedScene" uid="uid://c566vfi6kprxp" path="res://Pickups/Carrot/carrot.tscn" id="8_8cue1"]
[ext_resource type="PackedScene" uid="uid://dh3uoh5kn40gj" path="res://Pickups/Star/star.tscn" id="9_aon80"]
[ext_resource type="Texture2D" uid="uid://ksvbrrmonvec" path="res://World/Assets/props/vine.png" id="13_yxsbn"]
[ext_resource type="PackedScene" path="res://World/goal.tscn" id="14_goal"]
[ext_resource type="Script" path="res://World/fall_zone.gd" id="15_fall"]

[sub_resource type="TileSetAtlasSource" id="TileSetAtlasSource_4mssi"]
texture = ExtResource("1_wklou")
1:0/0 = 0
3:0/0 = 0
4:0/0 = 0
4:0/0/physics_layer_0/polygon_0/points = PackedVector2Array(-8, -8, 8, -8, 8, 8, -8, 8)
4:0/0/physics_layer_0/polygon_0/one_way = true
5:0/0 = 0
5:0/0/physics_layer_0/polygon_0/points = PackedVector2Array(-8, -8, 8, -8, 8, 8, -8, 8)
5:0/0/physics_layer_0/polygon_0/one_way = true
6:0/0 = 0
6:0/0/physics_layer_0/polygon_0/points = PackedVector2Array(-8, -8, 8, -8, 8, 8, -8, 8)
6:0/0/physics_layer_0/polygon_0/one_way = true
8:0/0 = 0
8:0/0/physics_layer_0/polygon_0/points = PackedVector2Array(-8, -8, 8, -8, 8, 8, -8, 8)
8:0/0/physics_layer_0/polygon_0/one_way = true
10:0/0 = 0
10:0/0/physics_layer_0/polygon_0/points = PackedVector2Array(-8, -8, 8, -8, 8, 8, -8, 8)
10:0/0/physics_layer_0/polygon_0/one_way = true
12:0/0 = 0
12:0/0/physics_layer_0/polygon_0/points = PackedVector2Array(-8, -8, 8, -8, 8, 8, -8, 8)
12:0/0/physics_layer_0/polygon_0/one_way = true
3:1/0 = 0
8:2/0 = 0
9:2/0 = 0
14:2/0 = 0
7:3/0 = 0
7:3/0/physics_layer_0/polygon_0/points = PackedVector2Array(-8, -8, 8, -8, 8, 8, -8, 8)
8:3/0 = 0
8:3/0/physics_layer_0/polygon_0/points = PackedVector2Array(-8, -8, 8, -8, 8, 8, -8, 8)
9:3/0 = 0
9:3/0/physics_layer_0/polygon_0/points = PackedVector2Array(-8, -8, 8, -8, 8, 8, -8, 8)
10:3/0 = 0
10:3/0/physics_layer_0/polygon_0/points = PackedVector2Array(-8, -8, 8, -8, 8, 8, -8, 8)
6:4/0 = 0
7:4/0 = 0
7:4/0/physics_layer_0/polygon_0/points = PackedVector2Array(-8, -8, 8, -8, 8, 8, -8, 8)
8:4/0 = 0
9:4/0 = 0
10:4/0 = 0
10:4/0/physics_layer_0/polygon_0/points = PackedVector2Array(-8, -8, 8, -8, 8, 8, -8, 8)
11:4/0 = 0
6:5/0 = 0
7:5/0 = 0
7:5/0/physics_layer_0/polygon_0/points = PackedVector2Array(-8, -8, 8, -8, 8, 8, -8, 8)
8:5/0 = 0
9:5/0 = 0
10:5/0 = 0
10:5/0/physics_layer_0/polygon_0/points = PackedVector2Array(-8, -8, 8, -8, 8, 8, -8, 8)
11:5/0 = 0
7:6/0 = 0
7:6/0/physics_layer_0/polygon_0/points = PackedVector2Array(-8, -8, 8, -8, 8, 8, -8, 8)
8:6/0 = 0
9:6/0 = 0
10:6/0 = 0
10:6/0/physics_layer_0/polygon_0/points = PackedVector2Array(-8, -8, 8, -8, 8, 8, -8, 8)
17:6/0 = 0
17:6/0/physics_layer_0/polygon_0/points = PackedVector2Array(-8, -8, 8, -8, 8, 8, -8, 8)
18:6/0 = 0
18:6/0/physics_layer_0/polygon_0/points = PackedVector2Array(-8, -8, 8, -8, 8, 8, -8, 8)
19:6/0 = 0
19:6/0/physics_layer_0/polygon_0/points = PackedVector2Array(-8, -8, 8, -8, 8, 8, -8, 8)
7:7/0 = 0
7:7/0/physics_layer_0/polygon_0/points = PackedVector2Array(-8, -8, 8, -8, 8, 8, -8, 8)
8:7/0 = 0
8:7/0/physics_layer_0/polygon_0/points = PackedVector2Array(-8, -8, 8, -8, 8, 8, -8, 8)
9:7/0 = 0
9:7/0/physics_layer_0/polygon_0/points = PackedVector2Array(-8, -8, 8, -8, 8, 8, -8, 8)
10:7/0 = 0
10:7/0/physics_layer_0/polygon_0/points = PackedVector2Array(-8, -8, 8, -8, 8, 8, -8, 8)
17:7/0 = 0
18:7/0 = 0
19:7/0 = 0
17:8/0 = 0
18:8/0 = 0
19:8/0 = 0
7:9/0 = 0
7:9/0/physics_layer_0/polygon_0/points = PackedVector2Array(-8, -8, 8, -8, 8, 8, -8, 8)
8:9/0 = 0
8:9/0/physics_layer_0/polygon_0/points = PackedVector2Array(-8, -8, 8, -8, 8, 8, -8, 8)
9:9/0 = 0
9:9/0/physics_layer_0/polygon_0/points = PackedVector2Array(-8, -8, 8, -8, 8, 8, -8, 8)
10:9/0 = 0
10:9/0/physics_layer_0/polygon_0/points = PackedVector2Array(-8, -8, 8, -8, 8, 8, -8, 8)
17:9/0 = 0
17:9/0/physics_layer_0/polygon_0/points = PackedVector2Array(-8, -8, 8, -8, 8, 8, -8, 8)
18:9/0 = 0
18:9/0/physics_layer_0/polygon_0/points = PackedVector2Array(-8, -8, 8, -8, 8, 8, -8, 8)
7:10/0 = 0
7:10/0/physics_layer_0/polygon_0/points = PackedVector2Array(-8, -8, 8, -8, 8, 8, -8, 8)
8:10/0 = 0
9:10/0 = 0
10:10/0 = 0
10:10/0/physics_layer_0/polygon_0/points = PackedVector2Array(-8, -8, 8, -8, 8, 8, -8, 8)
7:11/0 = 0
7:11/0/physics_layer_0/polygon_0/points = PackedVector2Array(-8, -8, 8, -8, 8, 8, -8, 8)
8:11/0 = 0
8:11/0/physics_layer_0/polygon_0/points = PackedVector2Array(-8, -8, 8, -8, 8, 8, -8, 8)
9:11/0 = 0
10:11/0 = 0
10:11/0/physics_layer_0/polygon_0/points = PackedVector2Array(-8, -8, 8, -8, 8, 8, -8, 8)
3:3/size_in_atlas = Vector2i(1, 2)
3:3/0 = 0
3:3/0/texture_origin = Vector2i(0, -8)
3:3/0/physics_layer_0/polygon_0/points = PackedVector2Array(-8, -8, 8, 8, 8, 24, -8, 24)
0:6/size_in_atlas = Vector2i(2, 2)
0:6/0 = 0
0:6/0/texture_origin = Vector2i(-8, -8)
0:6/0/physics_layer_0/polygon_0/points = PackedVector2Array(-8, 8, 24, -8, 24, 24, -8, 24)
3:6/size_in_atlas = Vector2i(2, 2)
3:6/0 = 0
3:6/0/texture_origin = Vector2i(-8, -8)
3:6/0/physics_layer_0/polygon_0/points = PackedVector2Array(-8, -8, 24, 8, 24, 24, -8, 24)
1:3/size_in_atlas = Vector2i(1, 2)
1:3/0 = 0
1:3/0/texture_origin = Vector2i(0, -8)
1:3/0/physics_layer_0/polygon_0/points = PackedVector2Array(-8, 8, 8, -8, 8, 24, -8, 24)
3:10/size_in_atlas = Vector2i(2, 2)
3:10/0 = 0
3:10/0/texture_origin = Vector2i(-8, -8)
3:10/0/physics_layer_0/polygon_0/points = PackedVector2Array(-8, -8, 24, -8, 24, 24, -8, 24)
12:6/size_in_atlas = Vector2i(4, 5)
12:6/0 = 0
0:10/size_in_atlas = Vector2i(2, 2)
0:10/0 = 0
0:10/0/texture_origin = Vector2i(-8, -8)
0:10/0/physics_layer_0/polygon_0/points = PackedVector2Array(-8, -8, 24, -8, 24, 24, -8, 24)
12:2/0 = 0
12:3/0 = 0
12:4/0 = 0
14:3/0 = 0
16:4/0 = 0
16:3/0 = 0
16:2/0 = 0
18:2/0 = 0
18:3/0 = 0
18:4/0 = 0

[sub_resource type="TileSet" id="TileSet_ufbka"]
physics_layer_0/collision_layer = 1
physics_layer_0/collision_mask = 0
sources/0 = SubResource("TileSetAtlasSource_4mssi")

[sub_resource type="RectangleShape2D" id="RectangleShape2D_fallzone"]
size = Vector2(5000, 100)

[node name="World2" type="Node2D" unique_id=492654115]

[node name="ParallaxBackground" parent="." unique_id=1237113930 instance=ExtResource("1_uh6rm")]

[node name="Decorations" type="Node2D" parent="." unique_id=1293677686]

[node name="Mushroom-brown" type="Sprite2D" parent="Decorations" unique_id=554052110]
position = Vector2(402, 160)
texture = ExtResource("2_0etpo")

[node name="Mushroom-red" type="Sprite2D" parent="Decorations" unique_id=1031390911]
position = Vector2(591, 67)
texture = ExtResource("3_lpec2")

[node name="Tree" type="Sprite2D" parent="Decorations" unique_id=931386681]
position = Vector2(248, 83)
texture = ExtResource("4_20e5r")

[node name="Tree2" type="Sprite2D" parent="Decorations" unique_id=931386682]
position = Vector2(2400, 83)
texture = ExtResource("4_20e5r")

[node name="Vine" type="Sprite2D" parent="Decorations" unique_id=346123292]
position = Vector2(1049, 25)
texture = ExtResource("13_yxsbn")

[node name="Vine2" type="Sprite2D" parent="Decorations" unique_id=1740392059]
position = Vector2(400, 22)
texture = ExtResource("13_yxsbn")

[node name="Rock" type="Sprite2D" parent="Decorations" unique_id=1381225840]
position = Vector2(1450, 163)
texture = ExtResource("6_f3vgq")

[node name="TileMap" type="TileMap" parent="." unique_id=1904224826]
tile_set = SubResource("TileSet_ufbka")
format = 2
layer_0/tile_data = PackedInt32Array(__TILE_DATA__)

[node name="Enemies" type="Node2D" parent="." unique_id=1410174707]

[node name="Slug" parent="Enemies" unique_id=1497086131 instance=ExtResource("5_o4885")]
position = Vector2(269, 164)

[node name="Slug2" parent="Enemies" unique_id=1995565182 instance=ExtResource("5_o4885")]
position = Vector2(464, 163)

[node name="PiranahPlant" parent="Enemies" unique_id=1797481271 instance=ExtResource("7_uqbqm")]
position = Vector2(569, 152)

[node name="Bee" parent="Enemies" unique_id=789989086 instance=ExtResource("6_6l5e8")]
position = Vector2(500, 45)

[node name="PiranahPlant2" parent="Enemies" unique_id=973720923 instance=ExtResource("7_uqbqm")]
position = Vector2(780, 75)

[node name="Bee2" parent="Enemies" unique_id=1037837107 instance=ExtResource("6_6l5e8")]
position = Vector2(1280, 50)

[node name="Slug3" parent="Enemies" unique_id=1111111111 instance=ExtResource("5_o4885")]
position = Vector2(1450, 164)

[node name="Slug4" parent="Enemies" unique_id=1111111112 instance=ExtResource("5_o4885")]
position = Vector2(1850, 164)

[node name="Bee3" parent="Enemies" unique_id=1111111113 instance=ExtResource("6_6l5e8")]
position = Vector2(2100, 60)

[node name="Slug5" parent="Enemies" unique_id=1111111117 instance=ExtResource("5_o4885")]
position = Vector2(2300, 164)

[node name="Bee4" parent="Enemies" unique_id=1111111118 instance=ExtResource("6_6l5e8")]
position = Vector2(2400, 60)

[node name="Pickups" type="Node2D" parent="." unique_id=186648387]

[node name="Carrot" parent="Pickups" unique_id=1173454715 instance=ExtResource("8_8cue1")]
position = Vector2(96, 88)

[node name="Carrot2" parent="Pickups" unique_id=51288067 instance=ExtResource("8_8cue1")]
position = Vector2(144, 88)

[node name="Carrot3" parent="Pickups" unique_id=370041027 instance=ExtResource("8_8cue1")]
position = Vector2(184, 88)

[node name="Carrot4" parent="Pickups" unique_id=499487656 instance=ExtResource("8_8cue1")]
position = Vector2(560, 32)

[node name="Carrot5" parent="Pickups" unique_id=850262994 instance=ExtResource("8_8cue1")]
position = Vector2(592, 32)

[node name="Carrot6" parent="Pickups" unique_id=166289352 instance=ExtResource("8_8cue1")]
position = Vector2(632, 32)

[node name="Carrot7" parent="Pickups" unique_id=1111111114 instance=ExtResource("8_8cue1")]
position = Vector2(1250, 100)

[node name="Carrot8" parent="Pickups" unique_id=1111111115 instance=ExtResource("8_8cue1")]
position = Vector2(1300, 80)

[node name="Carrot9" parent="Pickups" unique_id=1111111119 instance=ExtResource("8_8cue1")]
position = Vector2(1600, 80)

[node name="Carrot10" parent="Pickups" unique_id=1111111120 instance=ExtResource("8_8cue1")]
position = Vector2(2100, 80)

[node name="Carrot11" parent="Pickups" unique_id=1111111121 instance=ExtResource("8_8cue1")]
position = Vector2(2380, 80)

[node name="Star" parent="Pickups" unique_id=1856101220 instance=ExtResource("9_aon80")]
position = Vector2(230, 95)

[node name="Star2" parent="Pickups" unique_id=1856101221 instance=ExtResource("9_aon80")]
position = Vector2(1600, 45)

[node name="Star3" parent="Pickups" unique_id=1856101222 instance=ExtResource("9_aon80")]
position = Vector2(2380, 45)

[node name="Player" parent="." unique_id=1128907737 instance=ExtResource("2_3m2e0")]
position = Vector2(82, 152)

[node name="Goal" parent="." unique_id=1111111116 instance=ExtResource("14_goal")]
position = Vector2(2500, 145)

[node name="AudioStreamPlayer" type="AudioStreamPlayer" parent="." unique_id=1842792974]
stream = ExtResource("4_gmwgb")
autoplay = true

[node name="FallZone" type="Area2D" parent="." unique_id=999888777]
position = Vector2(1500, 400)
collision_layer = 0
collision_mask = 2
script = ExtResource("15_fall")

[node name="CollisionShape2D" type="CollisionShape2D" parent="FallZone"]
shape = SubResource("RectangleShape2D_fallzone")
"""

content = template.replace("__TILE_DATA__", tile_data_str)

with open('Scenes/Nivel2.tscn', 'w', encoding='utf-8') as f:
    f.write(content)

with open('Scenes/World2.tscn', 'w', encoding='utf-8') as f:
    f.write(content)

print("Successfully written Scenes/Nivel2.tscn and Scenes/World2.tscn")

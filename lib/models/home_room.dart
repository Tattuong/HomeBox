import 'package:flutter/material.dart';

enum HomeRoomId {
  all,
  livingRoom,
  bedroom,
  bathroom,
  kitchen,
}

class HomeRoom {
  final HomeRoomId id;
  final String nameKey;
  final IconData icon;
  final String? imageAsset;

  const HomeRoom({
    required this.id,
    required this.nameKey,
    required this.icon,
    this.imageAsset,
  });

  static const List<HomeRoom> all = [
    HomeRoom(id: HomeRoomId.all, nameKey: 'roomAll', icon: Icons.home_rounded),
    HomeRoom(
      id: HomeRoomId.livingRoom,
      nameKey: 'roomLiving',
      icon: Icons.weekend_outlined,
      imageAsset: 'assets/rooms/room_living.png',
    ),
    HomeRoom(
      id: HomeRoomId.bedroom,
      nameKey: 'roomBedroom',
      icon: Icons.bed_outlined,
      imageAsset: 'assets/rooms/room_bedroom.png',
    ),
    HomeRoom(
      id: HomeRoomId.bathroom,
      nameKey: 'roomBathroom',
      icon: Icons.bathtub_outlined,
      imageAsset: 'assets/rooms/room_bathroom.png',
    ),
    HomeRoom(
      id: HomeRoomId.kitchen,
      nameKey: 'roomKitchen',
      icon: Icons.kitchen_outlined,
      imageAsset: 'assets/rooms/room_kitchen.png',
    ),
  ];

  static HomeRoom byId(HomeRoomId id) => all.firstWhere((r) => r.id == id);

  String get storageKey => id.name;
}

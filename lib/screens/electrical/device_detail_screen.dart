import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../models/home_item.dart';
import '../../providers/home_provider.dart';
import '../../widgets/room_selector.dart';

class DeviceDetailScreen extends StatefulWidget {
  final HomeItem item;

  const DeviceDetailScreen({super.key, required this.item});

  @override
  State<DeviceDetailScreen> createState() => _DeviceDetailScreenState();
}

class _DeviceDetailScreenState extends State<DeviceDetailScreen> {
  late double _temperature;
  late bool _isOn;
  int _mode = 2;

  @override
  void initState() {
    super.initState();
    _temperature = widget.item.value ?? 24;
    _isOn = widget.item.isOn ?? false;
  }

  Future<void> _save() async {
    await context.read<HomeProvider>().updateItem(
          widget.item.copyWith(isOn: _isOn, value: _temperature),
        );
  }

  @override
  Widget build(BuildContext context) {
    final home = context.watch<HomeProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.item.title),
        actions: [IconButton(icon: const Icon(Icons.more_vert_rounded), onPressed: () {})],
      ),
      body: ListView(
        children: [
          RoomSelector(
            selected: home.selectedRoom,
            onChanged: home.selectRoom,
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 16, offset: const Offset(0, 4)),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(AppStrings.t(context, 'power'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                  Switch(
                    value: _isOn,
                    activeColor: AppColors.toggleOn,
                    onChanged: (v) {
                      setState(() => _isOn = v);
                      context.read<HomeProvider>().toggleDevice(widget.item.id);
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 280,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 240,
                  height: 240,
                  child: CircularProgressIndicator(
                    value: (_temperature - 10) / 30,
                    strokeWidth: 8,
                    backgroundColor: AppColors.surfaceVariant,
                    valueColor: const AlwaysStoppedAnimation(AppColors.toggleOn),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${_temperature.round()}°',
                      style: const TextStyle(fontSize: 56, fontWeight: FontWeight.w300),
                    ),
                    Text(
                      AppStrings.t(context, 'outsideTemp', {'temp': '14'}),
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Slider(
            value: _temperature,
            min: 10,
            max: 40,
            divisions: 30,
            activeColor: AppColors.toggleOn,
            label: '${_temperature.round()}°',
            onChanged: (v) => setState(() => _temperature = v),
            onChangeEnd: (_) => _save(),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _ModeButton(icon: Icons.ac_unit_outlined, label: AppStrings.t(context, 'modeAuto'), selected: _mode == 0, onTap: () => setState(() => _mode = 0)),
                _ModeButton(icon: Icons.ac_unit, label: AppStrings.t(context, 'modeCool'), selected: _mode == 1, onTap: () => setState(() => _mode = 1)),
                _ModeButton(icon: Icons.wb_sunny_outlined, label: AppStrings.t(context, 'modeHeat'), selected: _mode == 2, onTap: () => setState(() => _mode = 2)),
                _ModeButton(icon: Icons.water_drop_outlined, label: AppStrings.t(context, 'modeDry'), selected: _mode == 3, onTap: () => setState(() => _mode = 3)),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _ModeButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ModeButton({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: selected ? AppColors.primaryCoral.withValues(alpha: 0.15) : AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: selected ? AppColors.primaryCoral : AppColors.textSecondary),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              color: selected ? AppColors.primaryCoral : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

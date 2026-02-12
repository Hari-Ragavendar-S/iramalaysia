import '../models/busker_pod.dart';

class BuskerStorage {
  static final List<BuskerPod> _pods = [];

  static void addPod(BuskerPod pod) {
    _pods.add(pod);
  }

  static List<BuskerPod> getAllPods() {
    return List.from(_pods);
  }

  static BuskerPod? getPodById(String id) {
    try {
      return _pods.firstWhere((pod) => pod.id == id);
    } catch (e) {
      return null;
    }
  }

  static void removePod(String id) {
    _pods.removeWhere((pod) => pod.id == id);
  }

  static void updatePod(BuskerPod updatedPod) {
    final index = _pods.indexWhere((pod) => pod.id == updatedPod.id);
    if (index != -1) {
      _pods[index] = updatedPod;
    }
  }

  static void clearAll() {
    _pods.clear();
  }

  static int get podCount => _pods.length;
}
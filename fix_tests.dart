// ignore_for_file: avoid_print
import 'dart:io';

void main() {
  final dir = Directory('test');
  final files = dir.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart'));

  for (final file in files) {
    var content = file.readAsStringSync();
    var originalLength = content.length;
    
    // Fix platformDispatcher.view first
    content = content.replaceAll('tester.binding.platformDispatcher.view.physicalSizeTestValue', 'tester.view.physicalSize');
    content = content.replaceAll('tester.binding.platformDispatcher.view.devicePixelRatioTestValue', 'tester.view.devicePixelRatio');
    content = content.replaceAll('tester.binding.platformDispatcher.view.clearPhysicalSizeTestValue', 'tester.view.resetPhysicalSize');
    content = content.replaceAll('addTearDown(tester.binding.platformDispatcher.view.clearPhysicalSizeTestValue)', 'addTearDown(tester.view.resetPhysicalSize);\n      addTearDown(tester.view.resetDevicePixelRatio)');
    
    // Fix window
    content = content.replaceAll('tester.binding.window.physicalSizeTestValue', 'tester.view.physicalSize');
    content = content.replaceAll('tester.binding.window.devicePixelRatioTestValue', 'tester.view.devicePixelRatio');
    content = content.replaceAll('tester.binding.window.clearPhysicalSizeTestValue', 'tester.view.resetPhysicalSize');
    content = content.replaceAll('addTearDown(tester.binding.window.clearPhysicalSizeTestValue)', 'addTearDown(tester.view.resetPhysicalSize);\n      addTearDown(tester.view.resetDevicePixelRatio)');

    // For cases where we just replaced clearPhysicalSizeTestValue without addTearDown
    content = content.replaceAll('tester.view.resetPhysicalSize)', 'tester.view.resetPhysicalSize');
    
    if (content.length != originalLength) {
      file.writeAsStringSync(content);
      print('Fixed \${file.path}');
    }
  }
}

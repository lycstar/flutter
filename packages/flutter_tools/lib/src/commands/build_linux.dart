// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import '../base/analyze_size.dart';
import '../base/common.dart';
import '../build_info.dart';
import '../cache.dart';
import '../features.dart';
import '../globals.dart' as globals;
import '../linux/build_linux.dart';
import '../project.dart';
import '../runner/flutter_command.dart' show FlutterCommandResult;
import 'build.dart';

/// A command to build a linux desktop target through a build shell script.
class BuildLinuxCommand extends BuildSubCommand {
  BuildLinuxCommand({ bool verboseHelp = false }) {
    addCommonDesktopBuildOptions(verboseHelp: verboseHelp);
    argParser.addOption('target-platform',
      defaultsTo: 'linux-x64',
      allowed: <String>['linux-arm64', 'linux-x64'],
      help: 'The target platform for which the app is compiled.',
    );
    argParser.addOption('target-sysroot',
      defaultsTo: '/',
      help: 'The root filesystem path of target platform for which '
            'the app is compiled. This option is valid only '
            'when target-platform is linux-arm64.',
    );
  }

  @override
  final String name = 'linux';

  @override
  bool get hidden => !featureFlags.isLinuxEnabled || !globals.platform.isLinux;

  @override
  Future<Set<DevelopmentArtifact>> get requiredArtifacts async => <DevelopmentArtifact>{
    DevelopmentArtifact.linux,
  };

  @override
  String get description => 'Build a Linux desktop application.';

  @override
  Future<FlutterCommandResult> runCommand() async {
    final BuildInfo buildInfo = getBuildInfo();
    final FlutterProject flutterProject = FlutterProject.current();
    if (!featureFlags.isLinuxEnabled) {
      throwToolExit('"build linux" is not currently supported.');
    }
    if (!globals.platform.isLinux) {
      throwToolExit('"build linux" only supported on Linux hosts.');
    }
    await buildLinux(
      flutterProject.linux,
      buildInfo,
      target: targetFile,
      sizeAnalyzer: SizeAnalyzer(
        fileSystem: globals.fs,
        logger: globals.logger,
        flutterUsage: globals.flutterUsage,
      ),
      targetPlatform: getTargetPlatformForName(stringArg('target-platform')),
      targetSysroot: stringArg('target-sysroot'),
    );
    return FlutterCommandResult.success();
  }
}

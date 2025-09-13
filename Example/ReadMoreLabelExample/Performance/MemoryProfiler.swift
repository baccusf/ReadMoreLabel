import Foundation
import UIKit
import mach

// MARK: - Memory Profiler Service

/// Single Responsibility: Memory usage analysis and profiling
final class MemoryProfiler {

    // MARK: - Types

    struct MemorySnapshot {
        let timestamp: Date
        let residentMemoryMB: Double
        let virtualMemoryMB: Double

        var formattedResident: String {
            return String(format: "%.2f MB", residentMemoryMB)
        }

        var formattedVirtual: String {
            return String(format: "%.2f MB", virtualMemoryMB)
        }
    }

    struct MemoryUsageResult {
        let initialSnapshot: MemorySnapshot
        let finalSnapshot: MemorySnapshot
        let peakSnapshot: MemorySnapshot
        let testName: String

        var memoryIncrease: Double {
            return finalSnapshot.residentMemoryMB - initialSnapshot.residentMemoryMB
        }

        var formattedMemoryIncrease: String {
            let increase = memoryIncrease
            let sign = increase >= 0 ? "+" : ""
            return String(format: "%@%.2f MB", sign, increase)
        }
    }

    // MARK: - Constants

    private enum Constants {
        static let bytesToMB = 1024.0 * 1024.0
        static let measurementDelay: TimeInterval = 0.01 // 10ms
    }

    // MARK: - Private Properties

    private var snapshots: [MemorySnapshot] = []

    // MARK: - Public Interface

    /// Take a memory snapshot at current time
    func takeSnapshot() -> MemorySnapshot {
        let memoryInfo = getCurrentMemoryInfo()

        let snapshot = MemorySnapshot(
            timestamp: Date(),
            residentMemoryMB: Double(memoryInfo.resident_size) / Constants.bytesToMB,
            virtualMemoryMB: Double(memoryInfo.virtual_size) / Constants.bytesToMB
        )

        snapshots.append(snapshot)
        return snapshot
    }

    /// Start memory profiling session
    func startProfiling() -> MemorySnapshot {
        snapshots.removeAll()
        return takeSnapshot()
    }

    /// Measure memory usage during a specific operation
    func measureMemoryUsage<T>(testName: String, operation: () throws -> T) rethrows -> (result: T, memoryResult: MemoryUsageResult) {
        let initialSnapshot = startProfiling()

        let result = try operation()

        // Allow some time for memory allocation to be visible
        Thread.sleep(forTimeInterval: Constants.measurementDelay)

        let finalSnapshot = takeSnapshot()
        let peakSnapshot = findPeakMemoryUsage() ?? finalSnapshot

        let memoryResult = MemoryUsageResult(
            initialSnapshot: initialSnapshot,
            finalSnapshot: finalSnapshot,
            peakSnapshot: peakSnapshot,
            testName: testName
        )

        return (result: result, memoryResult: memoryResult)
    }

    /// Clear all recorded snapshots
    func clearSnapshots() {
        snapshots.removeAll()
    }

    // MARK: - Private Methods

    private func getCurrentMemoryInfo() -> mach_task_basic_info {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size) / 4

        let result = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &count)
            }
        }

        guard result == KERN_SUCCESS else {
            // Return empty info on failure
            return mach_task_basic_info()
        }

        return info
    }

    private func findPeakMemoryUsage() -> MemorySnapshot? {
        return snapshots.max { $0.residentMemoryMB < $1.residentMemoryMB }
    }
}

// MARK: - MemorySnapshot Extensions

extension MemoryProfiler.MemorySnapshot: CustomStringConvertible {
    var description: String {
        return "Memory: \(formattedResident) resident, \(formattedVirtual) virtual"
    }
}
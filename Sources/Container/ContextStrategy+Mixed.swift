///
///  ContextStrategy+Mixed.swift
///
///  Copyright 2017 Tony Stone
///
///  Licensed under the Apache License, Version 2.0 (the "License");
///  you may not use this file except in compliance with the License.
///  You may obtain a copy of the License at
///
///  http://www.apache.org/licenses/LICENSE-2.0
///
///  Unless required by applicable law or agreed to in writing, software
///  distributed under the License is distributed on an "AS IS" BASIS,
///  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
///  See the License for the specific language governing permissions and
///  limitations under the License.
///
///  Created by Tony Stone on 3/29/17.
///
import Swift
import TraceLog
import CoreData

extension ContextStrategy {

    ///
    /// A strategy that manages a nested (parent/child) viewContexts connected indirectly 
    /// through a root context to the `NSPersistentStoreCoordinator` and background contexts 
    /// that are connected directly to the `NSPersistentStoreCoordinator`.
    ///
    /// Changes made to BackgroundContexts are propagated directly to the persistentStore
    /// allowing merge policies to be set and respected. `viewContext` updates are done purely
    /// in memory and propagated to the persistentStore indirectly in a background thread
    /// through the rootContext.
    ///
    /// ```
    ///    backgroundContext ----------------\
    ///           |                           \
    ///           |                             -> PersistentStoreCoordinator
    ///           V                           /
    ///    viewContext -------> rootContext -/
    /// ```
    ///
    /// - Note: The view context will be kept up to date and persisted to the store when a background context is saved.
    ///
    public class Mixed: ContextStrategy, ContextStrategyType {

        private let rootContext: NSManagedObjectContext

        public required init(persistentStoreCoordinator: NSPersistentStoreCoordinator, errorHandler: @escaping AsyncErrorHandlerBlock) {

            /// Create the root context for saving
            self.rootContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
            self.rootContext.persistentStoreCoordinator = persistentStoreCoordinator

            /// Now the main thread context
            self.viewContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
            self.viewContext.parent = self.rootContext

            super.init(persistentStoreCoordinator: persistentStoreCoordinator, errorHandler: errorHandler)
        }

        deinit {
            NotificationCenter.default.removeObserver(self)
        }

        public let viewContext: NSManagedObjectContext

        public func newBackgroundContext<T: BackgroundContext>() -> T {

            let context = T(concurrencyType: NSManagedObjectContextConcurrencyType.privateQueueConcurrencyType)
            context.persistentStoreCoordinator = self.persistentStoreCoordinator

            /// Register to listen to this context
            NotificationCenter.default.addObserver(self, selector: #selector(self.handleContextDidSaveNotification(_:)), name: NSNotification.Name.NSManagedObjectContextDidSave, object: context)
            context.deinitBlock = { [weak context] in
                NotificationCenter.default.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: context)
            }
            return context
        }

        @objc fileprivate dynamic func handleContextDidSaveNotification(_ notification: Notification)  {

            self.viewContext.perform(onError: self.errorHandler) {

                ///
                /// Merge the changes from the edit context to the main context.
                ///
                self.viewContext.mergeChanges(fromContextDidSave: notification)

                ///
                /// Now save it to propagate the changes to the root.
                ///
                try self.viewContext.save()

                ////
                /// And finally save the root context to the persistent store
                /// on a background thread.
                ///
                self.rootContext.perform(onError: self.errorHandler) {
                    try self.rootContext.save()
                }
            }
        }
    }
}

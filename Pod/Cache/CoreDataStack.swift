/**
 *   CoreDataStack.swift
 *
 *   Copyright 2015 Tony Stone
 *
 *   Licensed under the Apache License, Version 2.0 (the "License");
 *   you may not use this file except in compliance with the License.
 *   You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 *   Unless required by applicable law or agreed to in writing, software
 *   distributed under the License is distributed on an "AS IS" BASIS,
 *   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *   See the License for the specific language governing permissions and
 *   limitations under the License.
 *
 *   Created by Tony Stone on 12/14/15.
 */
import Foundation
import CoreData
import TraceLog

@objc public final class CoreDataStack: NSObject  {
    
    private typealias CoreDataStackType = GenericCoreDataStack<NSPersistentStoreCoordinator, NSManagedObjectContext>
    
    private let impl: CoreDataStackType!
    
    /**
        Initializes the receiver with a managed object model.
    
        - parameters:
          - managedObjectModel: A managed object model.
          - storeNamePrefix: A unique name prefix for the persistent store to be created.
    */
    public init?(managedObjectModel model: NSManagedObjectModel, storeNamePrefix: String) {

        do {
            impl = try CoreDataStackType(managedObjectModel: model, storeNamePrefix: storeNamePrefix, logTag: String(CoreDataStack.self))
        
            super.init()
        } catch {
            return nil
        }
    }
    
    /**
        Initializes the receiver with a managed object model.
     
        - parameters:
          - managedObjectModel: A managed object model.
          - storeNamePrefix: A unique name prefix for the persistent store to be created.
          - configurationOptions: Optional configuration settings by persistent store config name (see ConfigurationOptionsType for structure)
     */
    public init?(managedObjectModel model: NSManagedObjectModel, storeNamePrefix: String, configurationOptions options: ConfigurationOptionsType) {
        
        do {
            impl = try CoreDataStackType(managedObjectModel: model, storeNamePrefix: storeNamePrefix, configurationOptions: options, logTag: String(CoreDataStack.self))
            
            super.init()
        } catch {
            return nil
        }
    }
    
    public func mainThreadContext () -> NSManagedObjectContext {
        return impl.mainThreadContext()
    }
    
    public func editContext () -> NSManagedObjectContext {
        return impl.editContext()
    }
}
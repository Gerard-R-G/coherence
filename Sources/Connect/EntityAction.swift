///
///  EntityAction.swift
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
///  Created by Tony Stone on 1/22/17.
///
import Foundation
import CoreData

public protocol EntityAction: Action {

    associatedtype ManagedObjectType: NSManagedObject

    ///
    /// Execute Action on a background thread.
    ///
    /// Actions that do not throw an exception or are canceled 
    /// will complete with an `ActionCompletionStatus.successful`
    /// in the `ActionProxy` that is returned when you execute
    /// this action.
    ///
    /// - SeeAlso: `ActionCompletionStatus`
    /// - SeeAlso: `ActionProxy`
    ///
    func execute(context: ActionContext) throws
}

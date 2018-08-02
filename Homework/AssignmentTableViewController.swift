//
//  AssignmentTableViewController.swift
//  Homework
//
//  Created by Ezra Celli on 5/15/18.
//  Copyright © 2018 Ezra Celli. All rights reserved.
//

import UIKit
import os.log
import UserNotifications

class AssignmentTableViewController: UITableViewController, UNUserNotificationCenterDelegate {
    
    
// MARK: Properties
    
    var assignments = [Assignment]()
    let sections = ["Due & overdue", "Due tomorrow", "Due this week", "Upcoming"]


// MARK: Initializations
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Register user notifications
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge], completionHandler: { (success, error) in
            if error != nil {
                os_log("User notifications unable to be registered", log: OSLog.default, type: .error)
            } else {
                os_log("User notifications have been registered", log: OSLog.default, type: .debug)
            }
        })
        UNUserNotificationCenter.current().delegate = self
        
        // Eliminate empty cells
        tableView.tableFooterView = UIView()
        
        // Load saved assignments
        if let savedAssignments = loadAssignments() {
            assignments += savedAssignments
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
// MARK: Table view data source

    // Returns number of sections
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    // Returns number of rows in each section
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfRowsInSection(section: section)
    }

    // Draws each cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Table view cells are reused and should be dequeued using a cell identifier.
        //let cellIdentifier = "AssignmentTableViewCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "AssignmentTableViewCell", for: indexPath) as? AssignmentTableViewCell  else {
            fatalError("The dequeued cell is not an instance of AssignmentTableViewCell.")
        }
        
        // Fetches the appropriate assignment for the data source layout.
        let row = currentRow(section: indexPath.section, indexRow: indexPath.row)
        let assignment = assignments[row]

        // Configure the cell...
        
        // Set the assignment name and class
        cell.nameLabel.text = assignment.assignmentName
        cell.classLabel.text = assignment.className
        
        // Get the assignment due date
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .none
        
        // Get the assignment due time
        let timeFormatter = DateFormatter()
        timeFormatter.dateStyle = .none
        timeFormatter.timeStyle = .short
        
        let date = dateFormatter.string(from: assignment.dueDate as Date) + " at " + timeFormatter.string(from: assignment.dueDate as Date)

        // Set the due date string
        if assignment.dueDate.timeIntervalSinceNow > 0 {
            cell.dueDateLabel.textColor = UIColor.black
            cell.dueDateLabel.text = date
        } else {
            cell.dueDateLabel.textColor = UIColor.red
            cell.dueDateLabel.text = "PAST DUE!"
        }

        return cell
    }

    // Enables support for conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    // Implements support for editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        // Get the current row
        let row = currentRow(section: indexPath.section, indexRow: indexPath.row)
        
        // We are deleting an assignment
        if editingStyle == .delete {
            // Remove the notification
            removeNotification(assignment: assignments[row])
            // Delete the row from the data source
            tableView.beginUpdates()
            tableView.deleteRows(at: [indexPath], with: .fade)
            assignments.remove(at: row)
            saveAssignments()
            tableView.endUpdates()
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    
    // Defines section headers
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section]
    }
    
    // Sets font size for header
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let header = view as? UITableViewHeaderFooterView else {
            fatalError("")
        }
        header.textLabel?.font = UIFont.boldSystemFont(ofSize: 16)
    }

    
// MARK: Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        switch(segue.identifier ?? "") {
            
            case "AddItem":
                os_log("Adding a new assignment...", log: OSLog.default, type: .debug)
            
            case "ShowDetail":
                os_log("Editing an assignment...", log: OSLog.default, type: .debug)
                guard let assignmentDetailViewController = segue.destination as? AssignmentViewController else {
                    fatalError("Unexpected destination: \(segue.destination)")
                }
                
                guard let selectedAssignmentCell = sender as? AssignmentTableViewCell else {
                    fatalError("Unexpected sender: \(String(describing: sender))")
                }
                
                guard let indexPath = tableView.indexPath(for: selectedAssignmentCell) else {
                    fatalError("The selected cell is not being displayed by the table")
                }
                
                // Get current row
                let row = currentRow(section: indexPath.section, indexRow: indexPath.row)
                
                // Get current assignment
                let selectedAssignment = assignments[row]
                assignmentDetailViewController.assignment = selectedAssignment
            
            case "ShowCourses":
                os_log("Showing all courses...", log: OSLog.default, type: .debug)
            
            default:
                fatalError("Unexpected Segue Identifier; \(String(describing: segue.identifier))")
        }
    }
    

// MARK: UNUserNotificationCenter
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound])
    }
    
    
// MARK: Private Methods
    
    // Gets the current row to factor in that indexPath.row resets to 0 at the start of each section
    private func currentRow(section: Int, indexRow: Int) -> Int {
        var corrector: Int = 0
        
        // Add the number of rows in all previous sections to current row
        for i in 0..<section {
            corrector += numberOfRowsInSection(section: i)
        }
        return indexRow + corrector
    }
    
    private func numberOfRowsInSection(section: Int) -> Int {
        
        // Get the first moment of tomorrow by truncating time and recreating the date
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .none
        let today = NSDate()
        guard var tomorrow = NSCalendar.current.date(byAdding: .day, value: 1, to: today as Date) else {
            os_log("Tomorrow's date unable to be retrieved", log: .default, type: .error)
            return 0
        }
        let tomorrowString = dateFormatter.string(from: tomorrow)
        tomorrow = dateFormatter.date(from: tomorrowString)!
        
        // Parameters
        let secondsLeftToday: Double = tomorrow.timeIntervalSince(today as Date)
        let SECONDS_IN_DAY: Double = 60.0 * 60.0 * 24.0
        let secondsLeftInWeek: Double = (today as Date).next(.monday).timeIntervalSince(today as Date)
        
        var matchingAssignments = [Assignment]()
        
        if section == 0 {                           // Number of overdue + due assignments
            for assignment in assignments {
                if assignment.dueDate.timeIntervalSinceNow < secondsLeftToday {
                    matchingAssignments.append(assignment)
                }
            }
            return matchingAssignments.count
        } else if section == 1 {                    // Number of assignments due in range 24 - 48 hours
            for assignment in assignments {
                if assignment.dueDate.timeIntervalSinceNow < (secondsLeftToday + SECONDS_IN_DAY) &&
                    assignment.dueDate.timeIntervalSinceNow >= secondsLeftToday {
                    matchingAssignments.append(assignment)
                }
            }
            return matchingAssignments.count
        } else if section == 2 {                    // Number of assignments due in range 24 hrs - 1 week
            for assignment in assignments {
                if assignment.dueDate.timeIntervalSinceNow < secondsLeftInWeek &&
                    assignment.dueDate.timeIntervalSinceNow >= (secondsLeftToday + SECONDS_IN_DAY) {
                    matchingAssignments.append(assignment)
                }
            }
            return matchingAssignments.count
        } else if section == 3 {                    // Number of assignments due in more than 1 week
            for assignment in assignments {
                if assignment.dueDate.timeIntervalSinceNow >= secondsLeftInWeek &&
                    assignment.dueDate.timeIntervalSinceNow > (secondsLeftToday + SECONDS_IN_DAY) {
                    matchingAssignments.append(assignment)
                }
            }
            return matchingAssignments.count
        } else {                                    // Something is messed up...
            return 0
        }
    }
    
    private func saveAssignments() {
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(assignments, toFile: Assignment.ArchiveURL.path)
        if isSuccessfulSave {
            os_log("Saving the assignments...", log: OSLog.default, type: .debug)
        } else {
            os_log("Failed to save the assignments.", log: OSLog.default, type: .error)
        }
    }
    
    private func loadAssignments() -> [Assignment]?  {
        return NSKeyedUnarchiver.unarchiveObject(withFile: Assignment.ArchiveURL.path) as? [Assignment]
    }
    
    private func scheduleNotification(assignment: Assignment) {
        // Define variables
        let timeDelay = assignment.dueDate.timeIntervalSinceNow - (60*60)
        if timeDelay < 0 {
            os_log("Cannot schedule a notification in the past!", log: OSLog.default, type: .error)
            return
        }
        
        // Define notification content
        let content = UNMutableNotificationContent()
        content.title = "Homework Reminder: \(assignment.assignmentName)"
        content.body = "Your assignment will be due in 1 hour. Is it done?"
        content.badge = 1
        let requestIdentifier = assignment.uuid
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeDelay, repeats: false)
        let request = UNNotificationRequest(identifier: requestIdentifier, content: content, trigger: trigger)
        
        // Add the notification request
        UNUserNotificationCenter.current().add(request, withCompletionHandler: { (error) in
            if error != nil {
                os_log("Assignment notification unable to be scheduled", log: OSLog.default, type: .error)
            } else {
                os_log("Assignment notification scheduled", log: OSLog.default, type: .debug)
            }
        })
    }
    
    private func removeNotification(assignment: Assignment) {
        let alreadyHappened = assignment.dueDate.timeIntervalSinceNow
        if alreadyHappened <= 0 {
            os_log("Notification already pushed", log: OSLog.default, type: .debug)
            return
        }
        
        let requestIdentifier = assignment.uuid
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [requestIdentifier])
        
        os_log("Notification removed", log: OSLog.default, type: .debug)
    }
    

// MARK: Actions
    @IBAction func unwindToAssignmentList(sender: UIStoryboardSegue) {
        // Attempt to downcast sender.source as an AssignmentViewController, if successful
        // and if sourceViewcontroller.assignment is not nil (there was an assignment passed)
        if let sourceViewController = sender.source as? AssignmentViewController, let assignment = sourceViewController.assignment {
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                // Get selected row
                let selectedRow = currentRow(section: selectedIndexPath.section, indexRow: selectedIndexPath.row)
                
                // Remove assignment's old notification
                removeNotification(assignment: assignments[selectedRow])
                
                // Edit the assignment
                assignments[selectedRow] = assignment
            } else {
                // Add a new assignment
                assignments.append(assignment)
            }
            
            // Create a new notification for assignment
            scheduleNotification(assignment: assignment)
            
            // Sort, save, and display all assignments
            assignments.sort(by: {$0.dueDate.timeIntervalSince($1.dueDate as Date) < 0})
            saveAssignments()
            tableView.reloadData()
        }
    }
}

/* BEGIN BLOCK
 * © 2018 StackOverflow user Sandeep (https://stackoverflow.com/users/654666/sandeep)
 * https://stackoverflow.com/questions/33397101/how-to-get-mondays-date-of-the-current-week-in-swift
 */
extension Date {
    
    static func today() -> Date {
        return Date()
    }
    
    func next(_ weekday: Weekday, considerToday: Bool = false) -> Date {
        return get(.Next,
                   weekday,
                   considerToday: considerToday)
    }
    
    func previous(_ weekday: Weekday, considerToday: Bool = false) -> Date {
        return get(.Previous,
                   weekday,
                   considerToday: considerToday)
    }
    
    func get(_ direction: SearchDirection,
             _ weekDay: Weekday,
             considerToday consider: Bool = false) -> Date {
        
        let dayName = weekDay.rawValue
        
        let weekdaysName = getWeekDaysInEnglish().map { $0.lowercased() }
        
        assert(weekdaysName.contains(dayName), "weekday symbol should be in form \(weekdaysName)")
        
        let searchWeekdayIndex = weekdaysName.index(of: dayName)! + 1
        
        let calendar = Calendar(identifier: .gregorian)
        
        if consider && calendar.component(.weekday, from: self) == searchWeekdayIndex {
            return self
        }
        
        var nextDateComponent = DateComponents()
        nextDateComponent.weekday = searchWeekdayIndex
        
        
        let date = calendar.nextDate(after: self,
                                     matching: nextDateComponent,
                                     matchingPolicy: .nextTime,
                                     direction: direction.calendarSearchDirection)
        
        return date!
    }
    
}

extension Date {
    func getWeekDaysInEnglish() -> [String] {
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = Locale(identifier: "en_US_POSIX")
        return calendar.weekdaySymbols
    }
    
    enum Weekday: String {
        case monday, tuesday, wednesday, thursday, friday, saturday, sunday
    }
    
    enum SearchDirection {
        case Next
        case Previous
        
        var calendarSearchDirection: Calendar.SearchDirection {
            switch self {
            case .Next:
                return .forward
            case .Previous:
                return .backward
            }
        }
    }
}
/* END BLOCK */

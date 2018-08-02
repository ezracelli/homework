//
//  CourseTableViewController.swift
//  Homework
//
//  Created by Ezra Celli on 5/16/18.
//  Copyright © 2018 Ezra Celli. All rights reserved.
//

import UIKit
import os.log

class CourseTableViewController: UITableViewController {

    
// MARK: Properties
    
    var courses = [Course]()
    var textFieldData: UITextField?
    var selectedIndexPath: IndexPath?
    
    
// MARK: Initializations
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Eliminate empty cells
        tableView.tableFooterView = UIView()
        
        // Load saved classes
        if let savedCourses = loadCourses() {
            courses += savedCourses
        }
    }

    
// MARK: Table View methods

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return courses.count
    }

    
    // Configure the cells
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Table view cells are reused and should be dequeued using a cell identifier.
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CourseTableViewCell", for: indexPath) as? CourseTableViewCell  else {
            fatalError("The dequeued cell is not an instance of CourseTableViewCell.")
        }
        
        // Fetches the appropriate assignment for the data source layout.
        let course = courses[indexPath.row]
        
        // Configure the cell...
        // Set the class name
        cell.courseName.text = course.courseName
        
        return cell
    }
    

    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.beginUpdates()
            tableView.deleteRows(at: [indexPath], with: .fade)
            courses.remove(at: indexPath.row)
            saveCourses()
            tableView.endUpdates()
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    
    // Edit the course when a course is selected (tapped)
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        os_log("Editing the course...", log: OSLog.default, type: .debug)
        
        // Present course editor pop up alert
        courseAlertController()
        
        // Get rid of highlighting
        tableView.deselectRow(at: indexPath, animated: false)
    }

    
// MARK: Actions
    
    // Navigation. Dismiss the scene without saving when the cancel button is pressed
    @IBAction func cancelButton(_ sender: UIBarButtonItem) {
        if let owningNavigationController = navigationController {
            owningNavigationController.popViewController(animated: true)
        }
    }
    
    // When + button is pushed, create a pop-up alert so the user can add a course
    @IBAction func addCourse(_ sender: UIBarButtonItem) {
        os_log("Adding a course...", log: OSLog.default, type: .debug)
        courseAlertController()
    }
    
    
// MARK: Private Methods
    
    // Adds or edits a course, using two handler methods below
    private func courseAlertController() {
        
        // Init the alert controller
        let alertController = UIAlertController(title: "Add Class", message: nil, preferredStyle: .alert)
        
        // Init the text field
        alertController.addTextField(configurationHandler: configureTextField)
        
        // Init "Save" and "Cancel" buttons
        let saveAction = UIAlertAction(title: "Save", style: .default, handler: saveHandler)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true)
    }
    
    // Assigns the raw text field data from the alert controller to textFieldData
    private func configureTextField(rawTextFieldData: UITextField) -> Void {
        textFieldData = rawTextFieldData
        textFieldData?.placeholder = "Course name"
    }
    
    // Stores and saves the desired course name to courses after converting to a Course
    private func saveHandler(alert: UIAlertAction) -> Void {
        if let newCourseName = textFieldData?.text as String?, let emptyText = newCourseName.isEmpty as Bool? {
            if !emptyText {
                
                if let selectedIndexPath = tableView.indexPathForSelectedRow {
                    // We want to edit an existing course
                    courses[selectedIndexPath.row] = (Course(courseName: newCourseName))
                    print(courses[selectedIndexPath.row].courseName)
                } else {
                    // We want to add a course
                    courses.append(Course(courseName: newCourseName))
                }
                
                // Update courses array, save array, and reload tableView
                courses.sort(by: {$0.courseName < $1.courseName})
                saveCourses()
                tableView.reloadData()
            }
        }
        
        // reset text field data
        textFieldData = nil
    }
    
    // Saves the courses to .../courses
    private func saveCourses() {
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(courses, toFile: Course.ArchiveURL.path)
        if isSuccessfulSave {
            os_log("Saving the courses...", log: OSLog.default, type: .debug)
        } else {
            os_log("Failed to save the courses.", log: OSLog.default, type: .error)
        }
    }
    
    // Loads the courses from .../courses
    private func loadCourses() -> [Course]?  {
        return NSKeyedUnarchiver.unarchiveObject(withFile: Course.ArchiveURL.path) as? [Course]
    }

}

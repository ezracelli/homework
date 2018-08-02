//
//  AssignmentViewController.swift
//  Homework
//
//  Created by Ezra Celli on 5/15/18.
//  Copyright © 2018 Ezra Celli. All rights reserved.
//

import UIKit
import os.log

class AssignmentViewController: UIViewController, UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate {

    
// MARK: Properties
    
    @IBOutlet weak var assignmentTextField: UITextField!
    @IBOutlet weak var assignmentDatePicker: UIDatePicker!
    @IBOutlet weak var assignmentClassPicker: UIPickerView!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    var assignment: Assignment?
    var courses = [String]()
    
    
// MARK: Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Handle the text field’s user input through delegate callbacks
        assignmentTextField.delegate = self
        
        if let savedCourses = loadCourses() {
            for course in savedCourses {
                courses.append(course)
            }
        }
        
        if let assignment = assignment {
            navigationItem.title = "Edit Assignment"
            assignmentTextField.text = assignment.assignmentName
            assignmentDatePicker.setDate(assignment.dueDate as Date, animated: true)
            if let row = courses.index(of: assignment.className) {
                assignmentClassPicker.selectRow(row, inComponent: 0, animated: true)
            }
        }
        
        // Update the save button (useful for when editing not adding)
        updateSaveButtonState()
    }
    
    
// MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Hide the keyboard
        assignmentTextField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        updateSaveButtonState()
    }
    
    
// MARK: UIPickerView
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return courses.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return courses[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // What to do with user-selected row
        // TODO = foods[row]
    }
    

// MARK: Navigation
    
    // Dismiss the scene without saving when the cancel button is pressed
    @IBAction func cancelButton(_ sender: UIBarButtonItem) {
        
        // Depending on style of presentation (modal or push presentation), this view controller needs to be dismissed in two different ways.
        let isPresentingInAddAssignmentMode = presentingViewController is UINavigationController
        
        if isPresentingInAddAssignmentMode {
            // We were adding a new assignment
            dismiss(animated: true, completion: nil)
        } else if let owningNavigationController = navigationController{
            // We were editing a assignment
            owningNavigationController.popViewController(animated: true)
        } else {
            // We were ?? who even knows
            fatalError("The MealViewController is not inside a navigation controller.")
        }
    }
    
    // This method lets you configure a view controller before it's presented
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        super.prepare(for: segue, sender: sender)
        
        // Configure the destination view controller only when the save button is pressed
        guard let button = sender as? UIBarButtonItem, button === saveButton else {
            os_log("The save button was not pressed, cancelling", log: OSLog.default, type: .debug)
            return
        }
        
        let assignmentName = assignmentTextField.text ?? ""
        let dueDate = assignmentDatePicker.date
        var className: String
        if !courses.isEmpty {
            className = courses[assignmentClassPicker.selectedRow(inComponent: 0)]
        } else {
            className = ""
        }
        let uuid = UUID().uuidString
        
        // Set the assignment to be passed to AssignmentTableViewController after the unwind segue
        assignment = Assignment(assignmentName: assignmentName, dueDate: dueDate as NSDate, className: className, uuid: uuid)
    }
    
    
// MARK: Actions
    
    @IBAction func dismissKeyboard(_ sender: UITapGestureRecognizer) {
        assignmentTextField.resignFirstResponder()
    }
    
    
//MARK: Private Methods
    
    private func updateSaveButtonState() {
        // Disable the Save button if the text field is empty
        let text = assignmentTextField.text ?? ""
        saveButton.isEnabled = !text.isEmpty
    }
    
    // Loads the courses from .../courses
    private func loadCourses() -> [String]?  {
        let rawSavedCourses = NSKeyedUnarchiver.unarchiveObject(withFile: Course.ArchiveURL.path) as? [Course]
        var courseNamesArray = [String]()
        if let savedCourses = rawSavedCourses {
            for course in savedCourses {
                 courseNamesArray.append(course.courseName)
            }
        }
        
        return courseNamesArray
    }
}


//
//  NotesViewModel.swift
//  NotesApp
//
//  Created by Assel Artykbay on 05.12.2024.
//

import Foundation
import UIKit
import CoreData

class NotesViewModel {
    private(set) var notes: [Note]?
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    var notesUpdated: (() -> Void)?

    func fetchNotes() {
        do {
            notes = try context.fetch(Note.fetchRequest())
            notesUpdated?()
        } catch {
            print("Error fetching notes: \(error)")
        }
    }



    func addNote(title: String, content: String) {
        let note = Note(context: context)
        note.title = title
        note.content = content
        note.addedDate = Date()

        do {
            try context.save()
            DispatchQueue.main.async {
                self.fetchNotes()
            }
        } catch {
            print(error)
        }
    }


    func deleteNote(_ item: Note) {
        context.delete(item)
        do {
            try context.save()
            fetchNotes()
        } catch{
            print(error)
        }
    }
    
    func updateNote(_ note: Note, title: String, content: String) {
        note.title = title
        note.content = content
        do {
            try context.save()
            fetchNotes()
        } catch{
            print(error)
        }
    }

    
    func categorizeNotesByDate(notes: [Note]) -> [String: [Note]] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        var categorizedNotes = [String: [Note]]()

        for note in notes {
            guard let addedDate = note.addedDate else { continue }
            
            let startOfNoteDay = calendar.startOfDay(for: addedDate)
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            let dateString = dateFormatter.string(from: addedDate)

            if calendar.isDateInToday(startOfNoteDay) {
                categorizedNotes["Today", default: []].append(note)
            } else if calendar.isDateInYesterday(startOfNoteDay) {
                categorizedNotes["Yesterday", default: []].append(note)
            } else {
                let monthString = dateFormatter.string(from: addedDate)
                categorizedNotes[monthString, default: []].append(note)
            }
        }
        
        for (key, value) in categorizedNotes {
            categorizedNotes[key] = value.sorted {
                $0.addedDate! < $1.addedDate!
            }
        }

        return categorizedNotes
    }

}


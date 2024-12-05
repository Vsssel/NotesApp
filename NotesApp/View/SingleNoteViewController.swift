//
//  SingleNoteViewController.swift
//  NotesApp
//
//  Created by Assel Artykbay on 05.12.2024.
//

import UIKit
import SnapKit

protocol SingleNoteDelegate: AnyObject {
    func didAddNote()
}

class SingleNoteViewController: UIViewController {
    weak var delegate: SingleNoteDelegate?
    private let viewModel = NotesViewModel()

    private var note: Note? // Store the note being edited

    private let titleTextField: UITextField = {
        let textField = UITextField()
        textField.font = .systemFont(ofSize: 28, weight: .bold)
        return textField
    }()

    private let contentTextView: UITextView = {
        let textView = UITextView()
        textView.font = .systemFont(ofSize: 18)
        return textView
    }()

    lazy var doneButton: UIBarButtonItem = {
        return UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneTapped))
    }()

    // Init method to accept an existing note
    init(note: Note? = nil) {
        self.note = note
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNoteData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        titleTextField.becomeFirstResponder()
    }

    private func setupUI() {
        view.backgroundColor = .systemBackground
        view.addSubview(titleTextField)
        view.addSubview(contentTextView)
        navigationItem.setRightBarButton(doneButton, animated: true)

        titleTextField.snp.makeConstraints { make in
            make.top.equalTo(view).offset(navigationController!.navigationBar.frame.height + 1)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(50)
        }

        contentTextView.snp.makeConstraints { make in
            make.top.equalTo(titleTextField.snp.bottom).offset(8)
            make.leading.trailing.bottom.equalToSuperview().inset(16)
        }
    }

    private func setupNoteData() {
        // If there's an existing note, populate the UI fields with it
        if let note = note {
            titleTextField.text = note.title
            contentTextView.text = note.content
        }
    }

    @objc private func doneTapped() {
        guard let title = titleTextField.text, !title.isEmpty,
              let content = contentTextView.text, !content.isEmpty else {
            navigationController?.popViewController(animated: true)
            return
        }

        if let existingNote = note {
            // Update the existing note if editing
            viewModel.updateNote(existingNote, title: title, content: content)
        } else {
            // Add a new note if there's no existing note
            viewModel.addNote(title: title, content: content)
        }

        delegate?.didAddNote()
        navigationController?.popViewController(animated: true)
    }
}

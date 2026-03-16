using System;

namespace LearningManagementSystem.GC
{
    // ── Quiz listing card ──────────────────────────────────────
    public class StudentQuizGC
    {
        public int QuizId { get; set; }
        public int SubjectId { get; set; }
        public int SessionId { get; set; }

        public string Title { get; set; }
        public string Description { get; set; }
        public int Duration { get; set; }   // minutes
        public int TotalMarks { get; set; }
        public int PassMarks { get; set; }
        public DateTime DueDate { get; set; }
        public bool IsEnabled { get; set; }

        public string SubjectName { get; set; }
        public string SubjectCode { get; set; }
        public int QuestionCount { get; set; }

        // Attempt info (null = not attempted)
        public int? ResultId { get; set; }
        public int? Score { get; set; }
        public DateTime? AttemptedOn { get; set; }

        // Computed state: Available / Attempted / Expired / Disabled
        public string State { get; set; }
    }

    // ── Single question during attempt ────────────────────────
    public class QuizQuestionGC
    {
        public int QuestionId { get; set; }
        public int QuizId { get; set; }
        public string QuestionText { get; set; }
        public string OptionA { get; set; }
        public string OptionB { get; set; }
        public string OptionC { get; set; }
        public string OptionD { get; set; }
        public string CorrectOption { get; set; }
        public int Marks { get; set; }
        public int OrderNo { get; set; }
    }

    // ── Attempt result ────────────────────────────────────────
    public class QuizAttemptGC
    {
        public int QuizId { get; set; }
        public int StudentId { get; set; }
        public int SocietyId { get; set; }
        public int InstituteId { get; set; }
        public int Score { get; set; }
        public int TotalMarks { get; set; }
        public int TimeTaken { get; set; }   // seconds
        public bool IsAutoSubmit { get; set; }
    }
}
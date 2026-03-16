using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using LearningManagementSystem.GC;

namespace LearningManagementSystem.BL
{
    public class AcademicSessionBL
    {
        DataLayer dl = new DataLayer();

        public void InsertSession(AcademicSessionGC obj)
        {
            List<SqlCommand> commands = new List<SqlCommand>();

            // If setting as current → reset old current session
            if (obj.IsCurrent)
            {
                SqlCommand resetCmd = new SqlCommand();
                resetCmd.CommandText = "UPDATE AcademicSessions SET IsCurrent = 0 WHERE InstituteId = @InstituteId";
                resetCmd.Parameters.AddWithValue("@InstituteId", obj.InstituteId);

                commands.Add(resetCmd);
            }

            // Insert new session
            SqlCommand insertCmd = new SqlCommand();
            insertCmd.CommandText = @"INSERT INTO AcademicSessions
                    (SocietyId, InstituteId, SessionName, StartDate, EndDate, IsActive, IsCurrent)
                    VALUES
                    (@SocietyId, @InstituteId, @SessionName, @StartDate, @EndDate, @IsActive, @IsCurrent)";

            insertCmd.Parameters.AddWithValue("@SocietyId", obj.SocietyId);
            insertCmd.Parameters.AddWithValue("@InstituteId", obj.InstituteId);
            insertCmd.Parameters.AddWithValue("@SessionName", obj.SessionName);
            insertCmd.Parameters.AddWithValue("@StartDate", obj.StartDate);
            insertCmd.Parameters.AddWithValue("@EndDate", obj.EndDate);
            insertCmd.Parameters.AddWithValue("@IsActive", obj.IsActive);
            insertCmd.Parameters.AddWithValue("@IsCurrent", obj.IsCurrent);

            commands.Add(insertCmd);

            // Execute in single transaction
            dl.ExecuteTransaction(commands);
        }

        public DataTable GetSessionsByInstitute(int instituteId)
        {
            SqlCommand cmd = new SqlCommand();
            cmd.CommandText = "SELECT * FROM AcademicSessions WHERE InstituteId = @InstituteId ORDER BY CreatedOn DESC";
            cmd.Parameters.AddWithValue("@InstituteId", instituteId);

            return dl.GetDataTable(cmd);
        }

        public DataTable GetCurrentSession(int instituteId)
        {
            SqlCommand cmd = new SqlCommand();
            cmd.CommandText = "SELECT * FROM AcademicSessions WHERE InstituteId = @InstituteId AND IsCurrent = 1";
            cmd.Parameters.AddWithValue("@InstituteId", instituteId);

            return dl.GetDataTable(cmd);
        }

        //public void SetCurrentSession(int sessionId, int instituteId)
        //{
        //    List<SqlCommand> commands = new List<SqlCommand>();

        //    SqlCommand resetCmd = new SqlCommand();
        //    resetCmd.CommandText = "UPDATE AcademicSessions SET IsCurrent = 0 WHERE InstituteId = @InstituteId";
        //    resetCmd.Parameters.AddWithValue("@InstituteId", instituteId);

        //    SqlCommand setCmd = new SqlCommand();
        //    setCmd.CommandText = "UPDATE AcademicSessions SET IsCurrent = 1 WHERE SessionId = @SessionId";
        //    setCmd.Parameters.AddWithValue("@SessionId", sessionId);

        //    commands.Add(resetCmd);
        //    commands.Add(setCmd);

        //    dl.ExecuteTransaction(commands);
        //}
        public void SetCurrentSession(int sessionId, int instituteId)
        {
            // 🔥 STEP 1: Get Previous Current Session
            int oldSessionId = 0;

            SqlCommand getOldCmd = new SqlCommand();
            getOldCmd.CommandText = @"
            SELECT TOP 1 SessionId 
            FROM AcademicSessions 
            WHERE InstituteId=@InstituteId AND IsCurrent=1";

            getOldCmd.Parameters.AddWithValue("@InstituteId", instituteId);

            DataTable dtOld = dl.GetDataTable(getOldCmd);

            if (dtOld.Rows.Count > 0)
                oldSessionId = Convert.ToInt32(dtOld.Rows[0]["SessionId"]);


            // 🔥 STEP 2: Reset All Sessions
            SqlCommand resetCmd = new SqlCommand();
            resetCmd.CommandText =
                "UPDATE AcademicSessions SET IsCurrent = 0 WHERE InstituteId = @InstituteId";
            resetCmd.Parameters.AddWithValue("@InstituteId", instituteId);

            dl.ExecuteCMD(resetCmd);


            // 🔥 STEP 3: Set New Current
            SqlCommand setCmd = new SqlCommand();
            setCmd.CommandText =
                "UPDATE AcademicSessions SET IsCurrent = 1 WHERE SessionId = @SessionId";
            setCmd.Parameters.AddWithValue("@SessionId", sessionId);

            dl.ExecuteCMD(setCmd);


            // 🔥 STEP 4: Clone Subjects (if previous session exists)
            if (oldSessionId > 0 && oldSessionId != sessionId)
            {
                AssignLevelSubjectBL AssignLevelSubjectBL = new AssignLevelSubjectBL();
                AssignLevelSubjectBL.CloneLevelSubjects(instituteId, oldSessionId, sessionId);
            }
        }
    }
}
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

        // ================= INSERT =================
        public void InsertSession(AcademicSessionGC obj)
        {
            List<SqlCommand> commands = new List<SqlCommand>();

            if (obj.IsCurrent)
            {
                SqlCommand resetCmd = new SqlCommand();
                resetCmd.CommandText =
                    "UPDATE AcademicSessions SET IsCurrent = 0 WHERE InstituteId = @InstituteId";
                resetCmd.Parameters.AddWithValue("@InstituteId", obj.InstituteId);
                commands.Add(resetCmd);
            }

            SqlCommand cmd = new SqlCommand();
            cmd.CommandText = @"INSERT INTO AcademicSessions
                (SocietyId, InstituteId, SessionName, StartDate, EndDate, IsActive, IsCurrent)
                VALUES
                (@SocietyId, @InstituteId, @SessionName, @StartDate, @EndDate, 1, @IsCurrent)";

            cmd.Parameters.AddWithValue("@SocietyId", obj.SocietyId);
            cmd.Parameters.AddWithValue("@InstituteId", obj.InstituteId);
            cmd.Parameters.AddWithValue("@SessionName", obj.SessionName);
            cmd.Parameters.AddWithValue("@StartDate", obj.StartDate);
            cmd.Parameters.AddWithValue("@EndDate", obj.EndDate);
            cmd.Parameters.AddWithValue("@IsCurrent", obj.IsCurrent);

            commands.Add(cmd);

            dl.ExecuteTransaction(commands);
        }

        // ================= UPDATE =================
        public void UpdateSession(AcademicSessionGC obj)
        {
            List<SqlCommand> commands = new List<SqlCommand>();

            if (obj.IsCurrent)
            {
                SqlCommand resetCmd = new SqlCommand();
                resetCmd.CommandText =
                    "UPDATE AcademicSessions SET IsCurrent = 0 WHERE InstituteId = @InstituteId";
                resetCmd.Parameters.AddWithValue("@InstituteId", obj.InstituteId);
                commands.Add(resetCmd);
            }

            SqlCommand cmd = new SqlCommand();
            cmd.CommandText = @"UPDATE AcademicSessions SET
                    SessionName=@SessionName,
                    StartDate=@StartDate,
                    EndDate=@EndDate,
                    IsCurrent=@IsCurrent
                WHERE SessionId=@SessionId";

            cmd.Parameters.AddWithValue("@SessionId", obj.SessionId);
            cmd.Parameters.AddWithValue("@SessionName", obj.SessionName);
            cmd.Parameters.AddWithValue("@StartDate", obj.StartDate);
            cmd.Parameters.AddWithValue("@EndDate", obj.EndDate);
            cmd.Parameters.AddWithValue("@IsCurrent", obj.IsCurrent);

            commands.Add(cmd);

            dl.ExecuteTransaction(commands);
        }

        // ================= DELETE =================
        public void Delete(int sessionId, int instituteId)
        {
            SqlCommand cmd = new SqlCommand();
            cmd.CommandText =
                "DELETE FROM AcademicSessions WHERE SessionId=@Id AND InstituteId=@InstituteId";

            cmd.Parameters.AddWithValue("@Id", sessionId);
            cmd.Parameters.AddWithValue("@InstituteId", instituteId);

            dl.ExecuteCMD(cmd);
        }

        // ================= GET ALL =================
        public DataTable GetSessionsByInstitute(int instituteId)
        {
            SqlCommand cmd = new SqlCommand();
            cmd.CommandText = @"SELECT * FROM AcademicSessions
                                WHERE InstituteId=@InstituteId
                                ORDER BY CreatedOn DESC";

            cmd.Parameters.AddWithValue("@InstituteId", instituteId);

            return dl.GetDataTable(cmd);
        }

        // ================= GET BY ID =================
        public DataTable GetById(int sessionId, int instituteId)
        {
            SqlCommand cmd = new SqlCommand();
            cmd.CommandText = @"SELECT * FROM AcademicSessions
                                WHERE SessionId=@Id AND InstituteId=@InstituteId";

            cmd.Parameters.AddWithValue("@Id", sessionId);
            cmd.Parameters.AddWithValue("@InstituteId", instituteId);

            return dl.GetDataTable(cmd);
        }

        // ================= SET CURRENT =================
        public void SetCurrentSession(int sessionId, int instituteId)
        {
            int oldSessionId = 0;

            SqlCommand getOldCmd = new SqlCommand();
            getOldCmd.CommandText = @"SELECT TOP 1 SessionId 
                                     FROM AcademicSessions 
                                     WHERE InstituteId=@InstituteId AND IsCurrent=1";
            getOldCmd.Parameters.AddWithValue("@InstituteId", instituteId);

            DataTable dtOld = dl.GetDataTable(getOldCmd);

            if (dtOld.Rows.Count > 0)
                oldSessionId = Convert.ToInt32(dtOld.Rows[0]["SessionId"]);

            // Reset
            SqlCommand resetCmd = new SqlCommand();
            resetCmd.CommandText =
                "UPDATE AcademicSessions SET IsCurrent = 0 WHERE InstituteId=@InstituteId";
            resetCmd.Parameters.AddWithValue("@InstituteId", instituteId);
            dl.ExecuteCMD(resetCmd);

            // Set new
            SqlCommand setCmd = new SqlCommand();
            setCmd.CommandText =
                "UPDATE AcademicSessions SET IsCurrent=1 WHERE SessionId=@SessionId";
            setCmd.Parameters.AddWithValue("@SessionId", sessionId);
            dl.ExecuteCMD(setCmd);

            // Clone data
            if (oldSessionId > 0 && oldSessionId != sessionId)
            {
                AssignLevelSubjectBL assign = new AssignLevelSubjectBL();
                assign.CloneLevelSubjects(instituteId, oldSessionId, sessionId);
            }
        }

        public DataTable GetCurrentSession(int instituteId)
        {
            SqlCommand cmd = new SqlCommand();
            cmd.CommandText = "SELECT * FROM AcademicSessions WHERE InstituteId = @InstituteId AND IsCurrent = 1";
            cmd.Parameters.AddWithValue("@InstituteId", instituteId);

            return dl.GetDataTable(cmd);
        }
    }
}

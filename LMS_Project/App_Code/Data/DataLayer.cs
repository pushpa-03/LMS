using System;
//using System.Activities;
using System.Collections;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Drawing;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using System.Web;
using System.Web.Hosting;

/// <summary>
/// Summary description for DataLayer
/// </summary>
public class DataLayer
{
    public DataLayer()
    {
        //
        // TODO: Add constructor logic here
        //
    }
    SqlConnection conObjERP = new SqlConnection(ConfigurationManager.ConnectionStrings["DefaultConnection"].ConnectionString.ToString());


    public void IntializeConnection()
    {
        if (conObjERP.State == ConnectionState.Open)
        {
            conObjERP.Close();
        }
        conObjERP.Open();
    }



    public void ExecuteCMD(SqlCommand cmd)
    {
        IntializeConnection();
        SqlTransaction sqlTrans = conObjERP.BeginTransaction();
        cmd.Connection = conObjERP;
        cmd.Transaction = sqlTrans;
        cmd.ExecuteNonQuery();
        sqlTrans.Commit();

    }

    public async void ExecuteCMDAsync(SqlCommand cmd)
    {
        await Task.Run(() =>
        {
            IntializeConnection();
            SqlTransaction sqlTrans = conObjERP.BeginTransaction();
            cmd.Connection = conObjERP;
            cmd.Transaction = sqlTrans;
            cmd.ExecuteNonQuery();
            sqlTrans.Commit();
        });


    }
    public string ReturnString(string qry)
    {

        string result = "";
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = qry;
        SqlDataReader dtrData = (SqlDataReader)(GetReader(cmd));
        if (dtrData.Read())
        {
            if (!string.IsNullOrEmpty(dtrData[0].ToString()))
            {
                result = dtrData[0].ToString();
            }
        }
        return result;
    }


    //public DataTable GetDataTable(SqlCommand cmd)
    //{
    //    IntializeConnection();
    //    cmd.Connection = conObjERP;
    //    SqlDataAdapter da = new SqlDataAdapter(cmd);
    //    DataTable dt = new DataTable();
    //    da.Fill(dt);
    //    if (dt != null)
    //    {
    //        return dt;
    //    }
    //    else
    //    {
    //        return null;
    //    }

    //}

    public DataTable GetDataTable(SqlCommand cmd)
    {
        try
        {
            IntializeConnection();
            cmd.Connection = conObjERP;
            SqlDataAdapter da = new SqlDataAdapter(cmd);
            DataTable dt = new DataTable();
            da.Fill(dt);
            return dt;
        }
        finally
        {
            // ✅ Always close connection to release it back to the pool
            if (conObjERP.State == ConnectionState.Open)
                conObjERP.Close();
        }
    }


    public Task<string> ExecuteAyncCMD(SqlCommand cmd)
    {
        return Task.Run(() =>
        {
            IntializeConnection();
            SqlTransaction sqlTrans = conObjERP.BeginTransaction();
            cmd.Connection = conObjERP;
            cmd.Transaction = sqlTrans;
            cmd.ExecuteNonQuery();
            sqlTrans.Commit();
            return "";
        });

    }
    public Task<DataSet> GetDataSetAsyncCMD(SqlCommand gstrQrystr)
    {
        return Task.Run(() =>
        {
            IntializeConnection();
            gstrQrystr.Connection = conObjERP;
            SqlDataAdapter SQLDA = new SqlDataAdapter(gstrQrystr);
            DataSet ds = new DataSet();
            SQLDA.Fill(ds);

            return ds;
        });
    }


    public Task<DataTable> GetDataTableAsync(SqlCommand cmd)
    {
        return Task.Run(() =>
        {
            IntializeConnection();
            cmd.Connection = conObjERP;
            SqlDataAdapter da = new SqlDataAdapter(cmd);
            DataTable dt = new DataTable();
            cmd.CommandTimeout = 5000;
            da.Fill(dt);
            if (dt != null)
            {
                return dt;
            }
            else
            {
                return null;
            }
        });


    }



    public async Task<DataSet> ReturnDataSetAsync(SqlCommand cmd)
    {
        IntializeConnection();
        cmd.Connection = conObjERP;
        cmd.CommandTimeout = 5000;

        using (SqlDataAdapter da = new SqlDataAdapter(cmd))
        {
            DataSet dt = new DataSet();
            await Task.Run(() => da.Fill(dt)); // Using Task.Run to perform Fill operation asynchronously

            if (dt.Tables.Count > 0 && dt.Tables[0].Rows.Count > 0)
            {
                return dt;
            }
        }

        return null;
    }
    public DataSet ReturnDataSet(SqlCommand cmd)
    {
        IntializeConnection();
        cmd.Connection = conObjERP;
        SqlDataAdapter da = new SqlDataAdapter(cmd);
        DataSet dt = new DataSet();
        da.Fill(dt);
        if (dt != null)
        {
            return dt;
        }
        else
        {
            return null;
        }
    }


    // Vishu 
    public SqlDataReader GetReader(SqlCommand cmd)
    {
        IntializeConnection();
        cmd.Connection = conObjERP;
        SqlDataReader read = cmd.ExecuteReader();
        return read;
    }

    public SqlDataReader GetReader(string cmdstr)
    {
        conObjERP.Close();
        SqlCommand cmd = new SqlCommand(cmdstr, conObjERP);
        cmd.Connection = conObjERP;
        conObjERP.Open();
        SqlDataReader dr = cmd.ExecuteReader();
        return dr;

    }

    public bool ExecuteTransaction(List<SqlCommand> commands)
    {
        SqlTransaction trans = null;
        try
        {
            IntializeConnection();
            trans = conObjERP.BeginTransaction();

            foreach (var cmd in commands)
            {
                cmd.Connection = conObjERP;
                cmd.Transaction = trans;
                cmd.ExecuteNonQuery();
            }

            trans.Commit();
            return true;
        }
        catch
        {
            trans?.Rollback();
            throw;
        }
        finally
        {
            if (conObjERP.State == ConnectionState.Open)
                conObjERP.Close();
        }
    }

}
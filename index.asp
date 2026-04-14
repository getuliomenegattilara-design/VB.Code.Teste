<%@ Language="VBScript" %>
<!-- #include file="config.asp" -->
<%
Dim msg
msg = ""

' --- Gravacao ---
If Request.Form("btnGravar") <> "" Then
    Dim nome
    nome = Trim(Request.Form("txtNome"))

    If nome = "" Then
        msg = "erro|Informe um nome antes de gravar."
    Else
        Dim conn, sql
        Set conn = GetConnection()
        sql = "INSERT INTO Pessoas (Nome) VALUES (?)"
        Dim cmd
        Set cmd = Server.CreateObject("ADODB.Command")
        cmd.ActiveConnection = conn
        cmd.CommandText = sql
        cmd.CommandType = 1
        cmd.Parameters.Append cmd.CreateParameter("@Nome", 200, 1, 100, nome)
        cmd.Execute
        Set cmd = Nothing
        conn.Close
        Set conn = Nothing
        msg = "ok|Nome gravado com sucesso!"
    End If
End If
%>
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Cadastro de Pessoas</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <style>
        body { background: #f0f4f8; }
        .card { border: none; border-radius: 12px; box-shadow: 0 4px 20px rgba(0,0,0,0.10); }
        .card-header {
            background: linear-gradient(135deg, #0078d4, #005fa3);
            border-radius: 12px 12px 0 0 !important;
            padding: 20px 24px;
        }
        .card-header h4 { color: #fff; margin: 0; font-weight: 600; letter-spacing: 0.3px; }
        .table thead th { background: #0078d4; color: #fff; border: none; font-weight: 500; }
        .table tbody tr:hover { background: #e8f1fb; }
        .table { border-radius: 8px; overflow: hidden; }
        .btn-gravar { min-width: 120px; }
        .badge-seq {
            background: #e3f0ff;
            color: #0078d4;
            font-weight: 600;
            border-radius: 20px;
            padding: 3px 10px;
            font-size: 13px;
        }
    </style>
</head>
<body>
<div class="container py-5">
    <div class="row justify-content-center">
        <div class="col-lg-7 col-md-9">

            <div class="card">
                <div class="card-header">
                    <h4><i class="bi bi-person-plus-fill me-2"></i>Cadastro de Pessoas</h4>
                </div>
                <div class="card-body p-4">

                    <%
                    If msg <> "" Then
                        Dim partes
                        partes = Split(msg, "|")
                        If partes(0) = "ok" Then
                            Response.Write "<div class=""alert alert-success alert-dismissible fade show"" role=""alert"">"
                            Response.Write "<i class=""bi bi-check-circle-fill me-2""></i>" & partes(1)
                            Response.Write "<button type=""button"" class=""btn-close"" data-bs-dismiss=""alert""></button>"
                            Response.Write "</div>"
                        Else
                            Response.Write "<div class=""alert alert-danger alert-dismissible fade show"" role=""alert"">"
                            Response.Write "<i class=""bi bi-exclamation-triangle-fill me-2""></i>" & partes(1)
                            Response.Write "<button type=""button"" class=""btn-close"" data-bs-dismiss=""alert""></button>"
                            Response.Write "</div>"
                        End If
                    End If
                    %>

                    <form method="POST" action="index.asp">
                        <label class="form-label fw-semibold">Nome</label>
                        <div class="input-group mb-4">
                            <span class="input-group-text"><i class="bi bi-person"></i></span>
                            <input type="text" class="form-control" name="txtNome" placeholder="Digite o nome..." maxlength="100" autofocus>
                            <button class="btn btn-primary btn-gravar" type="submit" name="btnGravar" value="1">
                                <i class="bi bi-floppy me-1"></i> Gravar
                            </button>
                        </div>
                    </form>

                    <h6 class="text-muted mb-3"><i class="bi bi-table me-1"></i> Ultimos 10 cadastros</h6>

                    <div class="table-responsive">
                        <table class="table table-hover table-bordered align-middle mb-0">
                            <thead>
                                <tr>
                                    <th style="width:50px">#</th>
                                    <th>Nome</th>
                                    <th style="width:180px">Data de Cadastro</th>
                                </tr>
                            </thead>
                            <tbody>
                            <%
                            Dim connGrid, rsGrid, sqlGrid
                            Set connGrid = GetConnection()
                            sqlGrid = "SELECT TOP 10 Id, Nome, DataCadastro FROM Pessoas ORDER BY Id DESC"
                            Set rsGrid = connGrid.Execute(sqlGrid)

                            If rsGrid.EOF Then
                                Response.Write "<tr><td colspan=""3"" class=""text-center text-muted fst-italic py-4"">Nenhum registro encontrado.</td></tr>"
                            Else
                                Dim contador
                                contador = 1
                                Do While Not rsGrid.EOF
                                    Response.Write "<tr>"
                                    Response.Write "<td><span class=""badge-seq"">" & contador & "</span></td>"
                                    Response.Write "<td>" & Server.HTMLEncode(rsGrid("Nome")) & "</td>"
                                    Response.Write "<td class=""text-muted"">" & rsGrid("DataCadastro") & "</td>"
                                    Response.Write "</tr>"
                                    contador = contador + 1
                                    rsGrid.MoveNext
                                Loop
                            End If

                            rsGrid.Close
                            Set rsGrid = Nothing
                            connGrid.Close
                            Set connGrid = Nothing
                            %>
                            </tbody>
                        </table>
                    </div>

                </div>
            </div>

        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>

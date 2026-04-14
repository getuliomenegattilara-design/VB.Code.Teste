<%@ Language="VBScript" %>
<!-- #include file="config.asp" -->
<%
Dim msg, acao
msg  = ""
acao = Request.Form("acao")

' --- GRAVAR ---
If acao = "gravar" Then
    Dim nome
    nome = Trim(Request.Form("txtNome"))
    If nome = "" Then
        msg = "erro|Informe um nome antes de gravar."
    Else
        Dim conn, cmd
        Set conn = GetConnection()
        Set cmd  = Server.CreateObject("ADODB.Command")
        cmd.ActiveConnection = conn
        cmd.CommandText = "INSERT INTO Pessoas (Nome) VALUES (?)"
        cmd.CommandType = 1
        cmd.Parameters.Append cmd.CreateParameter("@Nome", 200, 1, 100, nome)
        cmd.Execute
        Set cmd = Nothing : conn.Close : Set conn = Nothing
        msg = "ok|Pessoa cadastrada com sucesso!"
    End If
End If

' --- ALTERAR ---
If acao = "alterar" Then
    Dim nomeAlt, idAlt
    idAlt   = CInt(Request.Form("txtId"))
    nomeAlt = Trim(Request.Form("txtNomeAlt"))
    If nomeAlt = "" Then
        msg = "erro|Informe o nome para alterar."
    Else
        Dim connA, cmdA
        Set connA = GetConnection()
        Set cmdA  = Server.CreateObject("ADODB.Command")
        cmdA.ActiveConnection = connA
        cmdA.CommandText = "UPDATE Pessoas SET Nome = ? WHERE Id = ?"
        cmdA.CommandType = 1
        cmdA.Parameters.Append cmdA.CreateParameter("@Nome", 200, 1, 100, nomeAlt)
        cmdA.Parameters.Append cmdA.CreateParameter("@Id",   3,   1, 4,   idAlt)
        cmdA.Execute
        Set cmdA = Nothing : connA.Close : Set connA = Nothing
        msg = "ok|Registro alterado com sucesso!"
    End If
End If

' --- APAGAR ---
If acao = "apagar" Then
    Dim idDel, connD, cmdD
    idDel = CInt(Request.Form("txtIdDel"))
    Set connD = GetConnection()
    Set cmdD  = Server.CreateObject("ADODB.Command")
    cmdD.ActiveConnection = connD
    cmdD.CommandText = "DELETE FROM Pessoas WHERE Id = ?"
    cmdD.CommandType = 1
    cmdD.Parameters.Append cmdD.CreateParameter("@Id", 3, 1, 4, idDel)
    cmdD.Execute
    Set cmdD = Nothing : connD.Close : Set connD = Nothing
    msg = "ok|Registro excluido com sucesso!"
End If

' --- PAGINACAO E BUSCA ---
Const PAGE_SIZE = 3
Dim busca, pagina, totalReg, totalPag, offset

busca  = Trim(Request.QueryString("busca"))
pagina = Request.QueryString("pagina")
If pagina = "" Or Not IsNumeric(pagina) Then pagina = 1
pagina = CInt(pagina)
If pagina < 1 Then pagina = 1

' Conta total de registros com filtro
Dim connCount, rsCount, sqlCount
Set connCount = GetConnection()
If busca <> "" Then
    sqlCount = "SELECT COUNT(*) FROM Pessoas WHERE Nome LIKE '%" & Replace(busca, "'", "''") & "%'"
Else
    sqlCount = "SELECT COUNT(*) FROM Pessoas"
End If
Set rsCount = connCount.Execute(sqlCount)
totalReg = rsCount(0)
rsCount.Close : Set rsCount = Nothing
connCount.Close : Set connCount = Nothing

totalPag = Int((totalReg + PAGE_SIZE - 1) / PAGE_SIZE)
If totalPag < 1 Then totalPag = 1
If pagina > totalPag Then pagina = totalPag

offset = (pagina - 1) * PAGE_SIZE

' Monta URL base para paginacao preservando busca
Dim urlBase
urlBase = "index2.asp?busca=" & Server.URLEncode(busca) & "&pagina="
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
        :root {
            --accent: #10b981;
            --accent-dark: #059669;
            --bg: #0f172a;
            --surface: #1e293b;
            --surface2: #273548;
            --text: #e2e8f0;
            --muted: #94a3b8;
            --border: #334155;
        }

        body {
            background: var(--bg);
            color: var(--text);
            font-family: 'Segoe UI', Arial, sans-serif;
            min-height: 100vh;
        }

        .topbar {
            background: var(--surface);
            border-bottom: 1px solid var(--border);
            padding: 14px 32px;
            display: flex;
            align-items: center;
            gap: 12px;
        }
        .topbar .logo {
            width: 36px; height: 36px;
            background: var(--accent);
            border-radius: 8px;
            display: flex; align-items: center; justify-content: center;
            color: #fff; font-size: 18px;
        }
        .topbar h5 { margin: 0; font-weight: 700; color: var(--text); font-size: 17px; }
        .topbar span { color: var(--muted); font-size: 13px; }

        .main-card {
            background: var(--surface);
            border: 1px solid var(--border);
            border-radius: 14px;
            overflow: hidden;
        }
        .main-card .card-top {
            background: var(--surface2);
            padding: 12px 16px;
            border-bottom: 1px solid var(--border);
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 10px;
            flex-wrap: wrap;
        }
        .card-top-left { display: flex; align-items: center; gap: 10px; }
        .main-card .card-top h6 {
            margin: 0;
            font-weight: 600;
            font-size: 15px;
            color: var(--text);
        }
        .icon-box {
            width: 32px; height: 32px;
            background: rgba(16,185,129,0.15);
            border-radius: 8px;
            display: flex; align-items: center; justify-content: center;
            color: var(--accent); font-size: 16px;
            flex-shrink: 0;
        }

        /* Busca */
        .search-wrap { display: flex; gap: 6px; align-items: center; }
        .search-wrap .form-control {
            width: 200px;
            padding: 5px 10px;
            font-size: 13px;
            background: var(--surface) !important;
            border-color: var(--border) !important;
            color: var(--text) !important;
            border-radius: 6px;
        }
        .search-wrap .form-control::placeholder { color: var(--muted) !important; }
        .search-wrap .form-control:focus {
            box-shadow: 0 0 0 2px rgba(16,185,129,0.25) !important;
            border-color: var(--accent) !important;
        }
        .btn-search {
            background: rgba(16,185,129,0.15);
            color: var(--accent);
            border: 1px solid rgba(16,185,129,0.3);
            border-radius: 6px;
            padding: 5px 10px;
            font-size: 13px;
            cursor: pointer;
            transition: all 0.2s;
        }
        .btn-search:hover { background: rgba(16,185,129,0.3); }
        .btn-clear {
            background: transparent;
            color: var(--muted);
            border: 1px solid var(--border);
            border-radius: 6px;
            padding: 5px 10px;
            font-size: 13px;
            cursor: pointer;
            text-decoration: none;
            transition: all 0.2s;
        }
        .btn-clear:hover { color: var(--text); }

        /* Input cadastro */
        .form-control-dark, .input-group-text {
            background: var(--surface2) !important;
            border-color: var(--border) !important;
            color: var(--text) !important;
        }
        .form-control-dark::placeholder { color: var(--muted) !important; }
        .form-control-dark:focus {
            box-shadow: 0 0 0 3px rgba(16,185,129,0.25) !important;
            border-color: var(--accent) !important;
        }
        .input-group-text { color: var(--muted) !important; }

        .btn-accent {
            background: var(--accent);
            border: none;
            color: #fff;
            font-weight: 600;
            padding: 8px 22px;
            border-radius: 8px;
            transition: background 0.2s;
        }
        .btn-accent:hover { background: var(--accent-dark); color: #fff; }

        /* Tabela */
        .dark-table { width: 100%; border-collapse: collapse; font-size: 13px; }
        .dark-table thead th {
            background: var(--surface2);
            color: var(--muted);
            font-weight: 600;
            font-size: 11px;
            text-transform: uppercase;
            letter-spacing: 0.6px;
            padding: 8px 12px;
            border-bottom: 1px solid var(--border);
        }
        .dark-table tbody td {
            padding: 6px 12px;
            border-bottom: 1px solid var(--border);
            color: var(--text);
            vertical-align: middle;
        }
        .dark-table tbody tr:last-child td { border-bottom: none; }
        .dark-table tbody tr:hover { background: rgba(255,255,255,0.03); }

        .id-badge {
            display: inline-block;
            background: rgba(16,185,129,0.12);
            color: var(--accent);
            border-radius: 4px;
            padding: 1px 7px;
            font-weight: 700;
            font-size: 12px;
        }
        .date-text { color: var(--muted); font-size: 12px; }

        .btn-edit {
            background: transparent;
            color: #60a5fa;
            border: none;
            border-radius: 4px;
            padding: 2px 6px;
            font-size: 12px;
            cursor: pointer;
            transition: all 0.2s;
        }
        .btn-edit:hover { background: rgba(59,130,246,0.15); }

        .btn-del {
            background: transparent;
            color: #f87171;
            border: none;
            border-radius: 4px;
            padding: 2px 6px;
            font-size: 12px;
            cursor: pointer;
            transition: all 0.2s;
        }
        .btn-del:hover { background: rgba(239,68,68,0.15); }

        /* Paginacao */
        .pag-wrap {
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 10px 14px;
            border-top: 1px solid var(--border);
            font-size: 12px;
            color: var(--muted);
        }
        .pag-links { display: flex; gap: 4px; }
        .pag-btn {
            display: inline-flex; align-items: center; justify-content: center;
            width: 28px; height: 28px;
            border-radius: 6px;
            font-size: 12px;
            font-weight: 600;
            text-decoration: none;
            color: var(--muted);
            border: 1px solid var(--border);
            background: transparent;
            transition: all 0.2s;
        }
        .pag-btn:hover { background: var(--surface2); color: var(--text); }
        .pag-btn.ativo {
            background: var(--accent);
            border-color: var(--accent);
            color: #fff;
        }
        .pag-btn.desab { opacity: 0.35; pointer-events: none; }

        /* Alertas */
        .alert-ok {
            background: rgba(16,185,129,0.12);
            border: 1px solid rgba(16,185,129,0.3);
            color: #6ee7b7;
            border-radius: 10px;
            padding: 12px 16px;
            font-size: 14px;
        }
        .alert-err {
            background: rgba(239,68,68,0.12);
            border: 1px solid rgba(239,68,68,0.3);
            color: #fca5a5;
            border-radius: 10px;
            padding: 12px 16px;
            font-size: 14px;
        }

        /* Modal */
        .modal-content {
            background: var(--surface);
            border: 1px solid var(--border);
            border-radius: 14px;
            color: var(--text);
        }
        .modal-header { border-bottom: 1px solid var(--border); padding: 18px 24px; }
        .modal-footer { border-top: 1px solid var(--border); }
        .modal-title { font-weight: 700; font-size: 16px; }
        .btn-close { filter: invert(1); }

        .section-label {
            font-size: 11px;
            text-transform: uppercase;
            letter-spacing: 0.8px;
            color: var(--muted);
            font-weight: 700;
            margin-bottom: 8px;
        }
    </style>
</head>
<body>

<div class="topbar mb-4">
    <div class="logo"><i class="bi bi-people-fill"></i></div>
    <div>
        <h5>Pessoas</h5>
        <span>Gerenciamento de cadastro</span>
    </div>
</div>

<div class="container pb-5">
    <div class="row justify-content-center">
        <div class="col-lg-8">

            <%
            If msg <> "" Then
                Dim partes : partes = Split(msg, "|")
                If partes(0) = "ok" Then
                    Response.Write "<div class=""alert-ok mb-3""><i class=""bi bi-check-circle-fill me-2""></i>" & partes(1) & "</div>"
                Else
                    Response.Write "<div class=""alert-err mb-3""><i class=""bi bi-exclamation-triangle-fill me-2""></i>" & partes(1) & "</div>"
                End If
            End If
            %>

            <!-- Card novo cadastro -->
            <div class="main-card mb-4">
                <div class="card-top">
                    <div class="card-top-left">
                        <div class="icon-box"><i class="bi bi-person-plus"></i></div>
                        <h6>Novo Cadastro</h6>
                    </div>
                </div>
                <div class="p-4">
                    <form method="POST" action="index2.asp">
                        <input type="hidden" name="acao" value="gravar">
                        <div class="section-label">Nome da pessoa</div>
                        <div class="input-group">
                            <span class="input-group-text"><i class="bi bi-person"></i></span>
                            <input type="text" class="form-control form-control-dark" name="txtNome" placeholder="Digite o nome completo..." maxlength="100" autofocus>
                            <button class="btn btn-accent" type="submit">
                                <i class="bi bi-floppy me-1"></i> Gravar
                            </button>
                        </div>
                    </form>
                </div>
            </div>

            <!-- Card grid -->
            <div class="main-card">
                <div class="card-top">
                    <div class="card-top-left">
                        <div class="icon-box"><i class="bi bi-list-ul"></i></div>
                        <h6>
                            Registros
                            <span style="color:var(--muted); font-weight:400; font-size:13px; margin-left:6px">
                                (<%=totalReg%> encontrado<% If totalReg <> 1 Then Response.Write "s" End If %>)
                            </span>
                        </h6>
                    </div>
                    <!-- Busca -->
                    <form method="GET" action="index2.asp" class="search-wrap">
                        <input type="text" class="form-control" name="busca" placeholder="Buscar nome..." value="<%=Server.HTMLEncode(busca)%>">
                        <button type="submit" class="btn-search"><i class="bi bi-search"></i></button>
                        <% If busca <> "" Then %>
                        <a href="index2.asp" class="btn-clear" title="Limpar busca"><i class="bi bi-x-lg"></i></a>
                        <% End If %>
                    </form>
                </div>

                <div class="table-responsive">
                    <table class="dark-table">
                        <thead>
                            <tr>
                                <th>ID</th>
                                <th>Nome</th>
                                <th>Cadastrado em</th>
                                <th style="width:120px; text-align:center">Acoes</th>
                            </tr>
                        </thead>
                        <tbody>
                        <%
                        Dim connGrid, rsGrid, sqlGrid
                        Set connGrid = GetConnection()

                        Dim ini, fim
                        ini = offset + 1
                        fim = offset + PAGE_SIZE

                        If busca <> "" Then
                            sqlGrid = "SELECT Id, Nome, DataCadastro FROM (" & _
                                      "  SELECT Id, Nome, DataCadastro, ROW_NUMBER() OVER (ORDER BY Id DESC) AS RN" & _
                                      "  FROM Pessoas WHERE Nome LIKE '%" & Replace(busca, "'", "''") & "%'" & _
                                      ") T WHERE RN BETWEEN " & ini & " AND " & fim
                        Else
                            sqlGrid = "SELECT Id, Nome, DataCadastro FROM (" & _
                                      "  SELECT Id, Nome, DataCadastro, ROW_NUMBER() OVER (ORDER BY Id DESC) AS RN" & _
                                      "  FROM Pessoas" & _
                                      ") T WHERE RN BETWEEN " & ini & " AND " & fim
                        End If

                        Set rsGrid = connGrid.Execute(sqlGrid)

                        If rsGrid.EOF Then
                            Response.Write "<tr><td colspan=""4"" style=""text-align:center;color:#64748b;padding:30px;font-style:italic"">Nenhum registro encontrado.</td></tr>"
                        Else
                            Do While Not rsGrid.EOF
                                Dim rId, rNome, rData, nomeOriginal
                                rId          = rsGrid("Id")
                                nomeOriginal = rsGrid("Nome")
                                rNome        = Server.HTMLEncode(nomeOriginal)
                                rData        = rsGrid("DataCadastro")
                                Response.Write "<tr>"
                                Response.Write "  <td><span class=""id-badge"">" & rId & "</span></td>"
                                Response.Write "  <td>" & rNome & "</td>"
                                Response.Write "  <td><span class=""date-text"">" & rData & "</span></td>"
                                Response.Write "  <td style=""text-align:center"">"
                                Response.Write "    <button type=""button"" class=""btn-edit me-1"" data-id=""" & rId & """ data-nome=""" & Server.HTMLEncode(nomeOriginal) & """ data-acao=""editar""><i class=""bi bi-pencil""></i> Editar</button>"
                                Response.Write "    <button type=""button"" class=""btn-del"" data-id=""" & rId & """ data-nome=""" & Server.HTMLEncode(nomeOriginal) & """ data-acao=""apagar""><i class=""bi bi-trash""></i> Apagar</button>"
                                Response.Write "  </td>"
                                Response.Write "</tr>"
                                rsGrid.MoveNext
                            Loop
                        End If
                        rsGrid.Close : Set rsGrid = Nothing
                        connGrid.Close : Set connGrid = Nothing
                        %>
                        </tbody>
                    </table>
                </div>

                <!-- Paginacao -->
                <div class="pag-wrap">
                    <span>Pagina <%=pagina%> de <%=totalPag%></span>
                    <div class="pag-links">
                        <%
                        ' Anterior
                        If pagina <= 1 Then
                            Response.Write "<a class=""pag-btn desab""><i class=""bi bi-chevron-left""></i></a>"
                        Else
                            Response.Write "<a class=""pag-btn"" href=""" & urlBase & (pagina-1) & """><i class=""bi bi-chevron-left""></i></a>"
                        End If

                        ' Numeros
                        Dim p
                        For p = 1 To totalPag
                            If p = pagina Then
                                Response.Write "<a class=""pag-btn ativo"">" & p & "</a>"
                            Else
                                Response.Write "<a class=""pag-btn"" href=""" & urlBase & p & """>" & p & "</a>"
                            End If
                        Next

                        ' Proximo
                        If pagina >= totalPag Then
                            Response.Write "<a class=""pag-btn desab""><i class=""bi bi-chevron-right""></i></a>"
                        Else
                            Response.Write "<a class=""pag-btn"" href=""" & urlBase & (pagina+1) & """><i class=""bi bi-chevron-right""></i></a>"
                        End If
                        %>
                    </div>
                </div>

            </div>

        </div>
    </div>
</div>

<!-- Modal Editar -->
<div class="modal fade" id="modalEditar" tabindex="-1">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title"><i class="bi bi-pencil-square me-2 text-info"></i>Editar Pessoa</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <form method="POST" action="index2.asp">
                <input type="hidden" name="acao" value="alterar">
                <input type="hidden" name="txtId" id="editId">
                <div class="modal-body p-4">
                    <div class="section-label">Nome</div>
                    <div class="input-group">
                        <span class="input-group-text"><i class="bi bi-person"></i></span>
                        <input type="text" class="form-control form-control-dark" name="txtNomeAlt" id="editNome" maxlength="100">
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancelar</button>
                    <button type="submit" class="btn btn-accent"><i class="bi bi-floppy me-1"></i> Salvar</button>
                </div>
            </form>
        </div>
    </div>
</div>

<!-- Modal Confirmar Delete -->
<div class="modal fade" id="modalDeletar" tabindex="-1">
    <div class="modal-dialog modal-dialog-centered modal-sm">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title"><i class="bi bi-trash me-2 text-danger"></i>Confirmar exclusao</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <form method="POST" action="index2.asp">
                <input type="hidden" name="acao" value="apagar">
                <input type="hidden" name="txtIdDel" id="delId">
                <div class="modal-body p-4">
                    <p style="color:var(--muted); font-size:14px">Deseja realmente excluir <strong id="delNome" style="color:var(--text)"></strong>?</p>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancelar</button>
                    <button type="submit" class="btn btn-danger"><i class="bi bi-trash me-1"></i> Excluir</button>
                </div>
            </form>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script>
    document.addEventListener('DOMContentLoaded', function () {

        var modalEditar  = new bootstrap.Modal(document.getElementById('modalEditar'));
        var modalDeletar = new bootstrap.Modal(document.getElementById('modalDeletar'));

        document.querySelectorAll('[data-acao="editar"]').forEach(function (btn) {
            btn.addEventListener('click', function () {
                document.getElementById('editId').value   = this.getAttribute('data-id');
                document.getElementById('editNome').value = this.getAttribute('data-nome');
                modalEditar.show();
            });
        });

        document.querySelectorAll('[data-acao="apagar"]').forEach(function (btn) {
            btn.addEventListener('click', function () {
                document.getElementById('delId').value       = this.getAttribute('data-id');
                document.getElementById('delNome').innerText = this.getAttribute('data-nome');
                modalDeletar.show();
            });
        });

    });
</script>
</body>
</html>

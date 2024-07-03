unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ComCtrls,
  DOM,XMLRead, DateUtils;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Label1: TLabel;
    Memo1: TMemo;
    OpenDialog1: TOpenDialog;
    TreeView1: TTreeView;
    procedure Button1Click(Sender: TObject);
  private
    function ConvertToBrazilianDateFormat(const DateTimeStr: string): string;
    procedure ProcessarXMLPrefMunicipal;
    procedure ProcessNode(Node: TDOMNode; const TagName: string);

    procedure LoadAndProcessXMLFiles;
    procedure ProcessNota(Node: TDOMNode; ParentTreeNode: TTreeNode);
  public

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.Button1Click(Sender: TObject);
begin
  LoadAndProcessXMLFiles;
end;

procedure TForm1.ProcessarXMLPrefMunicipal;
var
  OpenDialog: TOpenDialog;
  i: Integer;
  Doc: TXMLDocument;
  Node: TDOMNode;
begin
  OpenDialog := TOpenDialog.Create(nil);
  try
    OpenDialog.Options := [ofAllowMultiSelect];
    OpenDialog.Filter := 'XML Files|*.xml';

    if OpenDialog.Execute then
    begin
      for i := 0 to OpenDialog.Files.Count - 1 do
      begin
        // Carrega o arquivo XML
        ReadXMLFile(Doc, OpenDialog.Files[i]);

        try
          // Processa a raiz do documento XML
          ProcessNode(Doc.DocumentElement, 'xNome');
        finally
          // Libera a memória do documento XML
          Doc.Free;
        end;
      end;
    end;
  finally
    OpenDialog.Free;
  end;
end;

procedure TForm1.ProcessNode(Node: TDOMNode; const TagName: string);
var
  ChildNode: TDOMNode;
begin
  // Verifica se o nome da tag corresponde ao nome desejado
  if Node.NodeName = TagName then
  begin
    // Processa o valor da tag
    ShowMessage(Node.TextContent);
  end;

  // Itera recursivamente sobre os filhos da node atual
  ChildNode := Node.FirstChild;
  while Assigned(ChildNode) do
  begin
    ProcessNode(ChildNode, TagName);
    ChildNode := ChildNode.NextSibling;
  end;
end;

procedure TForm1.LoadAndProcessXMLFiles;
var
  openDialog: TOpenDialog;
  i,count: Integer;
  Doc: TXMLDocument;
  NotasNode, NotaNode: TDOMNode;
  NotaTreeNode: TTreeNode;
begin
  openDialog := TOpenDialog.Create(nil);
  try
    openDialog.Options:= [ofAllowMultiSelect];
    openDialog.Filter:= 'XML Files|*.xml';

    if openDialog.Execute then
    begin
       //TreeView1.Items.Clear;  // Limpa a TreeView antes de adicionar novos itens

       count := 0;
      for i := 0 to openDialog.Files.Count -1 do
      begin
        //carrega o arquivo xml na memória, a partir do arquivo mostrado no opendialog
        ReadXMLFile(Doc,openDialog.Files[i]);

        try
          //obtendo a raiz do xml, no caso <notas>
          NotasNode := Doc.DocumentElement;

          if Assigned(NotasNode) and (NotasNode.NodeName = 'notas') then
          begin
            //iterar sobre cada tag nota dentro de notas
            NotaNode := NotasNode.FirstChild;
            while Assigned(NotaNode) do
            begin
              if NotaNode.NodeName = 'nota' then
              begin
                count := count +1;
                //processar cada tag nota
                //ProcessNota(NotaNode);

                // Adiciona um nó na TreeView para cada <nota>
                //NotaTreeNode := TreeView1.Items.Add(nil, 'Nota');

                // Processar cada tag <nota> e adicionar à TreeView
                ProcessNota(NotaNode, NotaTreeNode);
              end;
              NotaNode := NotaNode.NextSibling;
            end;
          end;
        finally
          Doc.Free;
        end;
      end;
    end;
  finally
    openDialog.Free;
    ShowMessage('Foram lidas ' + IntToStr(count) + ' notas fiscais');
      Label1.Caption:= 'Foram lidas ' + IntToStr(count) + ' notas fiscais';
  end;
end;

procedure TForm1.ProcessNota(Node: TDOMNode; ParentTreeNode: TTreeNode);
var
  ChildNode: TDOMNode;
  ChildTreeNode: TTreeNode;
  tomador, numero, data, valor, NodeText: String;
  DateTime: TDateTime;
begin
  tomador := '';
  numero := '';

  // iterar sobre as tags dentro de nota
  ChildNode := Node.FirstChild;
  while Assigned(ChildNode) do
  begin
    NodeText:= Format('%s: %s', [ChildNode.NodeName,ChildNode.TextContent]);

    // Adiciona o nó filho à TreeView
    //ChildTreeNode := TreeView1.Items.AddChild(ParentTreeNode, NodeText);
    //TreeView1.Update;

     // Processa a tag <servico> de maneira recursiva, se existir
    //if ChildNode.NodeName = 'servico' then
    //begin
    //  ProcessNota(ChildNode, ChildTreeNode);
    //end;

    // aqui eu ler e processar cada tah dentro de nota
    if ChildNode.NodeName = 'numero' then
      numero := ChildNode.TextContent
    else if ChildNode.NodeName = 'tomador_nome' then
      tomador := ChildNode.TextContent
    else if ChildNode.NodeName = 'data_emissao' then
      data := ChildNode.TextContent
     else if ChildNode.NodeName = 'valor_liquido' then
      valor := ChildNode.TextContent;

     data := ConvertToBrazilianDateFormat(data);


    ChildNode := ChildNode.NextSibling;
  end;
  Memo1.Lines.Append(data + ' - ' + numero + ' - ' + tomador + ' - ' + valor);
end;

function TForm1.ConvertToBrazilianDateFormat(const DateTimeStr: string): string;
var
  Year, Month, Day, Hour, Minute, Second: string;
  FormattedDateTime: string;
begin
  // Separar a data e a hora
  Year := Copy(DateTimeStr, 1, 4);
  Month := Copy(DateTimeStr, 6, 2);
  Day := Copy(DateTimeStr, 9, 2);
  Hour := Copy(DateTimeStr, 12, 2);
  Minute := Copy(DateTimeStr, 15, 2);
  Second := Copy(DateTimeStr, 18, 2);

  // Formatar para o padrão brasileiro
  FormattedDateTime := Day + '/' + Month + '/' + Year + ' ' + Hour + ':' + Minute + ':' + Second;

  Result := FormattedDateTime;
end;

end.


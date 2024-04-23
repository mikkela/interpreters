defprotocol Common.Ast.Node do
  @doc "Returns the literal value of the token"
  def token_literal(node)

  @doc "The type of the node"
  def node_type(node)

  @doc "Prints the node as a string"
  def to_string(node)
end

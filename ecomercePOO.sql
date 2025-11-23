use:@startuml
' Pacote/visão geral
package "Módulo: Autenticação" {
  abstract class Usuario {
    - id: int
    - nome: string
    - email: string
    - senha_hash: string
    + autenticar(password): bool
  }
  class Cliente {
    - cpf: string
    + verPedidos(): List<Pedido>
  }
  class Administrador {
    + gerenciarProdutos()
    + gerenciarPedidos()
  }
  Usuario <|-- Cliente
  Usuario <|-- Administrador
}

package "Módulo: Catálogo" {
  class Produto {
    - id: int
    - sku: string
    - nome: string
    - descricao: string
    - preco: decimal
    - estoque: int
    + ajustarEstoque(qtd:int)
  }
  class Categoria {
    - id: int
    - nome: string
  }
  class ImagemProduto {
    - id: int
    - produto_id: int
    - caminho: string
  }
  Categoria "1" <--o "0..*" Produto : pertence
  Produto "1" <--o "0..5" ImagemProduto : imagens
}

package "Módulo: Vendas" {
  class Carrinho {
    - id: int
    - cliente_id: int
    + adicionarItem(produto_id:int, qtd:int)
    + removerItem(item_id:int)
    + total(): decimal
  }
  class ItemCarrinho {
    - id: int
    - carrinho_id: int
    - produto_id: int
    - quantidade: int
  }
  class Pedido {
    - id: int
    - cliente_id: int
    - status: string
    - total: decimal
    - endereco_id: int
    - data_criacao: datetime
    + cancelar()
    + alterarStatus(status:string)
  }
  class ItemPedido {
    - id: int
    - pedido_id: int
    - produto_id: int
    - quantidade: int
    - preco_unitario: decimal
  }
  class Endereco {
    - id: int
    - cliente_id: int
    - cep: string
    - rua: string
    - numero: string
    - cidade: string
    - estado: string
  }

  Carrinho "1" -- "0..*" ItemCarrinho
  Pedido "1" -- "1..*" ItemPedido
  Cliente "1" -- "0..*" Pedido
  Cliente "1" -- "0..*" Endereco
  ItemPedido o-- Produto : referencia
  ItemCarrinho o-- Produto : referencia
}

package "Módulo: Integração / Pagamento" {
  interface GatewayPagamentoBase {
    + autorizarPagamento(dados): bool
    + capturarPagamento(id): bool
  }
  interface CalculadoraFreteBase {
    + calcular(endereco, peso, dimensoes): decimal
  }
  ' Exemplos de implementação (comentar para não detalhar implementação)
  class PagamentoPagSeguro
  class FreteCorreios

  GatewayPagamentoBase <|.. PagamentoPagSeguro
  CalculadoraFreteBase <|.. FreteCorreios
}

package "Persistência / Repositório" {
  interface ProdutoRepositorio {
    + salvar(Produto)
    + buscarPorId(id:int): Produto
    + buscarPorFiltro(filtros): List<Produto>
  }
  interface PedidoRepositorio {
    + salvar(Pedido)
    + buscarPorId(id:int): Pedido
  }
  ' Repositórios para abstrair SQLite
}

' Relacionamentos importantes (resumo)
Cliente "1" --> "0..1" Carrinho : possui
Pedido "1" --> "1" Endereco : entrega_em
Produto "1" --> "0..*" ItemPedido
Produto "1" --> "0..*" ItemCarrinho
@enduml
@startuml
left to right direction
actor Cliente as C
actor Administrador as A
rectangle Loja {
  C -- (Pesquisar produtos)
  C -- (Ver página de produto)
  C -- (Adicionar ao carrinho)
  C -- (Visualizar carrinho)
  C -- (Finalizar compra)
  C -- (Gerenciar perfil)
  C -- (Ver meus pedidos)

  A -- (Login Admin)
  A -- (Cadastrar/Editar/Remover Produto)
  A -- (Gerenciar Categorias)
  A -- (Ver pedidos)
  A -- (Alterar status do pedido)
  (Finalizar compra) .> (Criar pedido) : <<includes>>
  (Finalizar compra) .> (Pagamento) : <<includes>>
  (Finalizar compra) .> (Calcular frete) : <<includes>>
}
@enduml
-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema mydb
-- -----------------------------------------------------

-- -----------------------------------------------------
-- Schema mydb
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `mydb` DEFAULT CHARACTER SET utf8mb3 ;
USE `mydb` ;

-- -----------------------------------------------------
-- Table `mydb`.`cliente`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`cliente` (
  `idCliente` INT NOT NULL,
  `nome` VARCHAR(45) NULL DEFAULT NULL,
  `email` VARCHAR(45) NULL DEFAULT NULL,
  `senha` VARCHAR(45) NULL DEFAULT NULL,
  `telefone` VARCHAR(45) NULL DEFAULT NULL,
  `cpf` VARCHAR(45) NULL DEFAULT NULL,
  `data_cadastro` DATE NULL DEFAULT NULL,
  PRIMARY KEY (`idCliente`),
  UNIQUE INDEX `cpf_UNIQUE` (`cpf` ASC) VISIBLE,
  UNIQUE INDEX `email_UNIQUE` (`email` ASC) VISIBLE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb3;


-- -----------------------------------------------------
-- Table `mydb`.`carrinho`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`carrinho` (
  `idcarrinho` INT NOT NULL,
  `Cliente_idCliente` INT NOT NULL,
  `data_atualização` DATETIME NULL DEFAULT NULL,
  PRIMARY KEY (`idcarrinho`, `Cliente_idCliente`),
  INDEX `fk_carrinho_Cliente1_idx` (`Cliente_idCliente` ASC) VISIBLE,
  CONSTRAINT `fk_carrinho_Cliente1`
    FOREIGN KEY (`Cliente_idCliente`)
    REFERENCES `mydb`.`cliente` (`idCliente`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb3;


-- -----------------------------------------------------
-- Table `mydb`.`categoria`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`categoria` (
  `idcategoria` INT NOT NULL,
  `nome` VARCHAR(45) NULL DEFAULT NULL,
  `descrição` VARCHAR(45) NULL DEFAULT NULL,
  PRIMARY KEY (`idcategoria`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb3;


-- -----------------------------------------------------
-- Table `mydb`.`endereço`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`endereço` (
  `idendereço` INT NOT NULL,
  `id_Cliente` INT NOT NULL,
  `rua` VARCHAR(45) NULL DEFAULT NULL,
  `numero` VARCHAR(45) NULL DEFAULT NULL,
  `bairro` VARCHAR(45) NULL DEFAULT NULL,
  `cidade` VARCHAR(45) NULL DEFAULT NULL,
  `estado` VARCHAR(45) NULL DEFAULT NULL,
  `cep` VARCHAR(45) NULL DEFAULT NULL,
  PRIMARY KEY (`idendereço`, `id_Cliente`),
  INDEX `fk_endereço_Cliente_idx` (`id_Cliente` ASC) VISIBLE,
  CONSTRAINT `fk_endereço_Cliente`
    FOREIGN KEY (`id_Cliente`)
    REFERENCES `mydb`.`cliente` (`idCliente`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb3;


-- -----------------------------------------------------
-- Table `mydb`.`produto`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`produto` (
  `id_produto` INT NOT NULL,
  `id_categoria` INT NOT NULL,
  `nome` VARCHAR(45) NULL DEFAULT NULL,
  `descrição` VARCHAR(45) NULL DEFAULT NULL,
  `preço` DECIMAL(10,0) NULL DEFAULT NULL,
  `estoque` INT NULL DEFAULT NULL,
  `fabricante` VARCHAR(45) NULL DEFAULT NULL,
  `modelo_moto_compativel` VARCHAR(45) NULL DEFAULT NULL,
  PRIMARY KEY (`id_produto`, `id_categoria`),
  INDEX `fk_table1_categoria1_idx` (`id_categoria` ASC) VISIBLE,
  CONSTRAINT `fk_table1_categoria1`
    FOREIGN KEY (`id_categoria`)
    REFERENCES `mydb`.`categoria` (`idcategoria`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb3;


-- -----------------------------------------------------
-- Table `mydb`.`item_carrinho`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`item_carrinho` (
  `iditem_carrinho` INT NOT NULL,
  `carrinho_idcarrinho` INT NOT NULL,
  `produto_id_produto` INT NOT NULL,
  `quantidade` INT NULL DEFAULT NULL,
  PRIMARY KEY (`iditem_carrinho`, `carrinho_idcarrinho`, `produto_id_produto`),
  INDEX `fk_item_carrinho_carrinho1_idx` (`carrinho_idcarrinho` ASC) VISIBLE,
  INDEX `fk_item_carrinho_produto1_idx` (`produto_id_produto` ASC) VISIBLE,
  CONSTRAINT `fk_item_carrinho_carrinho1`
    FOREIGN KEY (`carrinho_idcarrinho`)
    REFERENCES `mydb`.`carrinho` (`idcarrinho`),
  CONSTRAINT `fk_item_carrinho_produto1`
    FOREIGN KEY (`produto_id_produto`)
    REFERENCES `mydb`.`produto` (`id_produto`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb3;


-- -----------------------------------------------------
-- Table `mydb`.`pedido`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`pedido` (
  `idpedido` INT NOT NULL,
  `Cliente_idCliente` INT NOT NULL,
  `endereço_idendereço` INT NOT NULL,
  `data_pedido` DATETIME NULL DEFAULT NULL,
  `status` VARCHAR(45) NULL DEFAULT NULL,
  `valor_total` DECIMAL(10,0) NULL DEFAULT NULL,
  PRIMARY KEY (`idpedido`, `Cliente_idCliente`, `endereço_idendereço`),
  INDEX `fk_pedido_Cliente1_idx` (`Cliente_idCliente` ASC) VISIBLE,
  INDEX `fk_pedido_endereço1_idx` (`endereço_idendereço` ASC) VISIBLE,
  CONSTRAINT `fk_pedido_Cliente1`
    FOREIGN KEY (`Cliente_idCliente`)
    REFERENCES `mydb`.`cliente` (`idCliente`),
  CONSTRAINT `fk_pedido_endereço1`
    FOREIGN KEY (`endereço_idendereço`)
    REFERENCES `mydb`.`endereço` (`idendereço`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb3;


-- -----------------------------------------------------
-- Table `mydb`.`itens_pedido`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`itens_pedido` (
  `iditens_pedido` INT NOT NULL,
  `pedido_idpedido` INT NOT NULL,
  `produto_id_produto` INT NOT NULL,
  `quantidade` INT NULL DEFAULT NULL,
  `preco_unitario` DECIMAL(10,0) NULL DEFAULT NULL,
  PRIMARY KEY (`iditens_pedido`, `pedido_idpedido`, `produto_id_produto`),
  INDEX `fk_itens_pedido_pedido1_idx` (`pedido_idpedido` ASC) VISIBLE,
  INDEX `fk_itens_pedido_produto1_idx` (`produto_id_produto` ASC) VISIBLE,
  CONSTRAINT `fk_itens_pedido_pedido1`
    FOREIGN KEY (`pedido_idpedido`)
    REFERENCES `mydb`.`pedido` (`idpedido`),
  CONSTRAINT `fk_itens_pedido_produto1`
    FOREIGN KEY (`produto_id_produto`)
    REFERENCES `mydb`.`produto` (`id_produto`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb3;


-- -----------------------------------------------------
-- Table `mydb`.`pagamento`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`pagamento` (
  `idpagamento` INT NOT NULL,
  `pedido_idpedido` INT NOT NULL,
  `tipo_pagamento` VARCHAR(45) NULL DEFAULT NULL,
  `valor` DECIMAL(10,0) NULL DEFAULT NULL,
  `status_pagamento` VARCHAR(45) NULL DEFAULT NULL,
  `data_pagamento` DATETIME NULL DEFAULT NULL,
  PRIMARY KEY (`idpagamento`, `pedido_idpedido`),
  INDEX `fk_pagamento_pedido1_idx` (`pedido_idpedido` ASC) VISIBLE,
  CONSTRAINT `fk_pagamento_pedido1`
    FOREIGN KEY (`pedido_idpedido`)
    REFERENCES `mydb`.`pedido` (`idpedido`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb3;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;


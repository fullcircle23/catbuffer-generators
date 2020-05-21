# pylint: disable=R0911,R0912

# For creating embedded transaction builders
from .EmbeddedTransactionBuilder import EmbeddedTransactionBuilder
% for name in sorted(generator.schema):
<%
    layout = generator.schema[name].get("layout", [{type:""}])
    entityTypeValue = next(iter([x for x in layout if x.get('type','') == 'EntityType']),{}).get('value',0)
%>\
% if entityTypeValue > 0 and 'Aggregate' not in name:
from .Embedded${name}Builder import Embedded${name}Builder
% endif
% endfor
# For creating transaction builders
from .TransactionBuilder import TransactionBuilder
from .AggregateBondedTransactionBuilder import AggregateBondedTransactionBuilder
from .AggregateCompleteTransactionBuilder import AggregateCompleteTransactionBuilder
% for name in sorted(generator.schema):
<%
    layout = generator.schema[name].get("layout", [{type:""}])
    entityTypeValue = next(iter([x for x in layout if x.get('type','') == 'EntityType']),{}).get('value',0)
%>\
% if entityTypeValue > 0 and 'Aggregate' not in name:
from .${name}Builder import ${name}Builder
% endif
% endfor


class TransactionBuilderFactory:
    """Factory in charge of creating the specific transaction builder from the binary payload.

        Todo: Add detail description.
    """

    @classmethod
    def createEmbeddedTransactionBuilder(cls, payload) -> EmbeddedTransactionBuilder:
        """
        It creates the specific embedded transaction builder from the payload bytes.
        Args:
            payload: bytes
        Returns:
            the EmbeddedTransactionBuilder subclass
        """
        headerBuilder = EmbeddedTransactionBuilder.loadFromBinary(payload)
        entityType = headerBuilder.getType().value
% for name in generator.schema:
<%
    layout = generator.schema[name].get("layout", [{type:""}])
    entityTypeValue = next(iter([x for x in layout if x.get('type','') == 'EntityType']),{}).get('value',0)
%>\
% if entityTypeValue > 0 and 'Aggregate' not in name:
        if entityType == ${entityTypeValue}:
            return Embedded${name}Builder.loadFromBinary(payload)
% endif
% endfor
        return headerBuilder

    @classmethod
    def createTransactionBuilder(cls, payload) -> TransactionBuilder:
        """
        It creates the specific transaction builder from the payload bytes.
        Args:
            payload: bytes
        Returns:
            the TransactionBuilder subclass
        """
        headerBuilder = TransactionBuilder.loadFromBinary(payload)
        entityType = headerBuilder.getType().value
% for name in generator.schema:
<%
    layout = generator.schema[name].get("layout", [{type:""}])
    entityTypeValue = next(iter([x for x in layout if x.get('type','') == 'EntityType']),{}).get('value',0)
%>\
    % if (entityTypeValue > 0):
        if entityType == ${entityTypeValue}:
            return ${name}Builder.loadFromBinary(payload)
    % endif
% endfor
        return headerBuilder
{% docs kaia_traces_block_no %}

The block number of this transaction.

{% enddocs %}


{% docs kaia_traces_blocktime %}

The block timestamp of this transaction.

{% enddocs %}


{% docs kaia_traces_call_data %}

The raw JSON data for this trace.

{% enddocs %}


{% docs kaia_traces_from %}

The sending address of this trace. This is not necessarily the from address of the transaction. 

{% enddocs %}


{% docs kaia_traces_gas %}

The gas supplied for this trace.

{% enddocs %}


{% docs kaia_traces_gas_used %}

The gas used for this trace.

{% enddocs %}


{% docs kaia_traces_identifier %}

This field represents the position and type of the trace within the transaction. 

{% enddocs %}


{% docs kaia_trace_index %}

The index of the trace within the transaction.

{% enddocs %}


{% docs kaia_traces_input %}

The input data for this trace.

{% enddocs %}


{% docs kaia_traces_output %}

The output data for this trace.

{% enddocs %}


{% docs kaia_traces_sub %}

The amount of nested sub traces for this trace.

{% enddocs %}


{% docs kaia_traces_table_doc %}

This table contains flattened trace data for internal contract calls on the kaia Blockchain. Hex encoded fields can be decoded to integers by using `utils.udf_hex_to_int()`.

{% enddocs %}


{% docs kaia_traces_to %}

The receiving address of this trace. This is not necessarily the to address of the transaction. 

{% enddocs %}


{% docs kaia_traces_tx_hash %}

The transaction hash for the trace. Please note, this is not necessarily unique in this table as transactions frequently have multiple traces. 

{% enddocs %}


{% docs kaia_traces_type %}

The type of internal transaction. Common trace types are `CALL`, `DELEGATECALL`, and `STATICCALL`.

{% enddocs %}


{% docs kaia_traces_value %}

The amount of ETH transferred in this trace.

{% enddocs %}



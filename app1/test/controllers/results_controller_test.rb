require 'test_helper'

class ResultsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @result = results(:one)
  end

  test "should get index" do
    get results_url
    assert_response :success
  end

  test "should get new" do
    get new_result_url
    assert_response :success
  end

  test "should create result" do
    assert_difference('Result.count') do
      post results_url, params: { result: { business_id: @result.business_id, consumable_id: @result.consumable_id, device_id: @result.device_id, notes: @result.notes, patient_id: @result.patient_id, result_datetime: @result.result_datetime, user_id: @result.user_id, value: @result.value } }
    end

    assert_redirected_to result_url(Result.last)
  end

  test "should show result" do
    get result_url(@result)
    assert_response :success
  end

  test "should get edit" do
    get edit_result_url(@result)
    assert_response :success
  end

  test "should update result" do
    patch result_url(@result), params: { result: { business_id: @result.business_id, consumable_id: @result.consumable_id, device_id: @result.device_id, notes: @result.notes, patient_id: @result.patient_id, result_datetime: @result.result_datetime, user_id: @result.user_id, value: @result.value } }
    assert_redirected_to result_url(@result)
  end

  test "should destroy result" do
    assert_difference('Result.count', -1) do
      delete result_url(@result)
    end

    assert_redirected_to results_url
  end
end
